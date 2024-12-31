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