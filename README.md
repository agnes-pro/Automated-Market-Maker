# Automated Market Maker (AMM) Smart Contract

A decentralized exchange implementation in Clarity featuring automated market making and yield farming capabilities.

## Features

- **Liquidity Pools**

  - Create token pair pools
  - Add/remove liquidity
  - Track user liquidity positions
  - Automatic price discovery using constant product formula

- **Token Swaps**

  - Decentralized token exchange
  - 0.3% swap fee
  - Constant product market maker (x \* y = k)
  - Slippage protection

- **Yield Farming**

  - Reward distribution for liquidity providers
  - Configurable reward rates
  - Minimum liquidity requirements
  - Per-block reward calculation

- **Governance**
  - Token allowlist management
  - Reward rate adjustment
  - Contract ownership controls

## Contract Architecture

### Core Components

1. **Token Standard**

   - Implements SIP-010 fungible token trait
   - Standardized interface for token interactions

2. **Liquidity Management**

   - Pool creation and tracking
   - Liquidity share calculation
   - Reserve management

3. **Swap Engine**

   - Constant product formula implementation
   - Fee calculation
   - Price impact handling

4. **Yield Distribution**
   - Reward accrual tracking
   - Claim mechanism
   - Rate adjustment system

## Usage

### Creating a Pool

```clarity
(contract-call? .amm create-pool token1 token2 amount1 amount2)
```

### Adding Liquidity

```clarity
(contract-call? .amm add-liquidity token1 token2 amount1 amount2)
```

### Performing Swaps

```clarity
(contract-call? .amm swap-tokens token-in token-out amount)
```

### Claiming Rewards

```clarity
(contract-call? .amm claim-yield-rewards token1 token2)
```

## Security Features

1. **Access Controls**

   - Owner-only administrative functions
   - Protected token allowlist
   - Validated token pair operations

2. **Safety Checks**

   - Amount validation
   - Pool existence verification
   - Balance sufficiency checks
   - Slippage protection

3. **Error Handling**
   - Comprehensive error codes
   - Clear error messages
   - Failed transaction reversal

## Constants

| Name                      | Value     | Description                              |
| ------------------------- | --------- | ---------------------------------------- |
| REWARD_RATE_PER_BLOCK     | 10        | Base reward rate per block               |
| MIN_LIQUIDITY_FOR_REWARDS | 100       | Minimum liquidity for reward eligibility |
| MAX_REWARD_RATE           | 1,000,000 | Maximum allowed reward rate              |

## Error Codes

| Code | Description             |
| ---- | ----------------------- |
| u1   | Insufficient funds      |
| u2   | Invalid amount          |
| u3   | Pool does not exist     |
| u4   | Unauthorized access     |
| u5   | Transfer failed         |
| u6   | Invalid token           |
| u7   | Invalid token pair      |
| u8   | Zero amount             |
| u9   | Maximum amount exceeded |
| u10  | Same token error        |

## Development

### Prerequisites

- Clarinet
- Stacks blockchain environment

### Testing

```bash
clarinet check    # Run contract checks
clarinet test     # Run test suite
```

## Best Practices

1. **Liquidity Provision**

   - Provide balanced token amounts
   - Monitor pool share percentage
   - Consider impermanent loss

2. **Token Swaps**

   - Account for slippage
   - Check price impact
   - Verify output amounts

3. **Yield Farming**
   - Meet minimum liquidity requirements
   - Regular reward claims
   - Monitor reward rates

## Contract Dependencies

- `ft-trait`: SIP-010 Fungible Token Standard implementation
