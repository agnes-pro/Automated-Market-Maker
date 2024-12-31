;; Title: Automated Market Maker (AMM) with Yield Farming

;; Summary:
;; An automated market maker (AMM) smart contract that enables decentralized token swaps,
;; liquidity provision, and yield farming rewards. Uses the constant product formula
;; for price discovery and includes governance features.

;; Description:
;; This contract implements core DEX functionality including:
;; - Liquidity pool creation and management
;; - Token swaps with 0.3% fee
;; - Liquidity provision tracking
;; - Yield farming rewards for liquidity providers
;; - Governance controls for reward rate adjustment
;; - Token allowlist management

;; Import external trait
(use-trait ft-trait .ft-trait.ft-trait)

;; Error constants
(define-constant ERR-INSUFFICIENT-FUNDS (err u1))
(define-constant ERR-INVALID-AMOUNT (err u2))  
(define-constant ERR-POOL-NOT-EXISTS (err u3))
(define-constant ERR-UNAUTHORIZED (err u4))
(define-constant ERR-TRANSFER-FAILED (err u5))
(define-constant ERR-INVALID-TOKEN (err u6))
(define-constant ERR-INVALID-PAIR (err u7))
(define-constant ERR-ZERO-AMOUNT (err u8))
(define-constant ERR-MAX-AMOUNT-EXCEEDED (err u9))
(define-constant ERR-SAME-TOKEN (err u10))

;; Protocol constants
(define-constant REWARD-RATE-PER-BLOCK u10)
(define-constant MIN-LIQUIDITY-FOR-REWARDS u100)
(define-constant MAX-TOKENS-PER-POOL u2)
(define-constant MAX-REWARD-RATE u1000000)
(define-constant MAX-UINT u340282366920938463463374607431768211455) ;; 2^128 - 1

;; Data mappings
(define-map allowed-tokens 
    principal 
    bool
)

(define-map liquidity-pools 
    {token1: principal, token2: principal} 
    {
        total-liquidity: uint,
        token1-reserve: uint,
        token2-reserve: uint
    }
)

(define-map user-liquidity 
    {user: principal, token1: principal, token2: principal} 
    {liquidity-shares: uint}
)

(define-map yield-rewards 
    {user: principal, token: principal} 
    {pending-rewards: uint}
)

;; Contract variables
(define-data-var contract-owner principal tx-sender)
(define-data-var reward-rate uint REWARD-RATE-PER-BLOCK)

;; Governance functions

;; Adds a token to the allowlist
(define-public (add-allowed-token (token principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-UNAUTHORIZED)
        (asserts! (not (is-eq token (var-get contract-owner))) ERR-INVALID-TOKEN)
        (ok (map-set allowed-tokens token true))
    )
)

;; Core AMM functions

;; Creates a new liquidity pool for a token pair
(define-public (create-pool 
    (token1 <ft-trait>) 
    (token2 <ft-trait>) 
    (initial-amount1 uint) 
    (initial-amount2 uint)
)
    (let (
        (token1-principal (contract-of token1))
        (token2-principal (contract-of token2))
    )
        (asserts! (validate-token-pair token1-principal token2-principal) ERR-INVALID-PAIR)
        (asserts! (validate-amount initial-amount1) ERR-INVALID-AMOUNT)
        (asserts! (validate-amount initial-amount2) ERR-INVALID-AMOUNT)
        (asserts! (is-none (map-get? liquidity-pools {token1: token1-principal, token2: token2-principal})) ERR-POOL-NOT-EXISTS)
        
        (try! (contract-call? token1 transfer initial-amount1 tx-sender (as-contract tx-sender) none))
        (try! (contract-call? token2 transfer initial-amount2 tx-sender (as-contract tx-sender) none))
        
        (map-set liquidity-pools 
            {token1: token1-principal, token2: token2-principal}
            {
                total-liquidity: initial-amount1,
                token1-reserve: initial-amount1,
                token2-reserve: initial-amount2
            }
        )
        
        (map-set user-liquidity 
            {user: tx-sender, token1: token1-principal, token2: token2-principal}
            {liquidity-shares: initial-amount1}
        )
        
        (ok true)
    )
)

;; Adds liquidity to an existing pool
(define-public (add-liquidity 
    (token1 <ft-trait>) 
    (token2 <ft-trait>) 
    (amount1 uint) 
    (amount2 uint)
)
    (let (
        (token1-principal (contract-of token1))
        (token2-principal (contract-of token2))
    )
        (asserts! (validate-token-pair token1-principal token2-principal) ERR-INVALID-PAIR)
        (asserts! (validate-amount amount1) ERR-INVALID-AMOUNT)
        (asserts! (validate-amount amount2) ERR-INVALID-AMOUNT)
        
        (let (
            (pool (unwrap! (map-get? liquidity-pools {token1: token1-principal, token2: token2-principal}) ERR-POOL-NOT-EXISTS))
            (optimal-amount2 (/ (* amount1 (get token2-reserve pool)) (get token1-reserve pool)))
        )
            (asserts! (<= amount2 optimal-amount2) ERR-INVALID-AMOUNT)
            
            (try! (contract-call? token1 transfer amount1 tx-sender (as-contract tx-sender) none))
            (try! (contract-call? token2 transfer amount2 tx-sender (as-contract tx-sender) none))
            
            (map-set liquidity-pools 
                {token1: token1-principal, token2: token2-principal}
                {
                    total-liquidity: (+ (get total-liquidity pool) amount1),
                    token1-reserve: (+ (get token1-reserve pool) amount1),
                    token2-reserve: (+ (get token2-reserve pool) amount2)
                }
            )
            
            (let (
                (existing-shares (default-to u0 
                    (get liquidity-shares 
                        (map-get? user-liquidity {user: tx-sender, token1: token1-principal, token2: token2-principal})
                    )
                ))
            )
                (map-set user-liquidity 
                    {user: tx-sender, token1: token1-principal, token2: token2-principal}
                    {liquidity-shares: (+ existing-shares amount1)}
                )
                
                (ok true)
            )
        )
    )
)