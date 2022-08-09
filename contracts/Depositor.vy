# @version 0.3.4

from vyper.interfaces import ERC20

# # In goerli
# # Token address
# USDC: constant(address) = 0x5FfbaC75EFc9547FBc822166feD19B05Cd5890bb
# WETH: constant(address) = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6

# # Address of NonfungiblePositionManager
# NonfungiblePositionManagerAddress: constant(address) = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88
# # Address of Uniswap V3 SwapRouter
# SwapRouterAddress: constant(address) = 0xE592427A0AEce92De3Edee1F18E0157C05861564

# In mainnet
# Token address
USDC: constant(address) = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
WETH: constant(address) = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

# Address of NonfungiblePositionManager
NonfungiblePositionManagerAddress: constant(address) = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88
# Address of Uniswap V3 SwapRouter
SwapRouterAddress: constant(address) = 0xE592427A0AEce92De3Edee1F18E0157C05861564

# Fee tier of Pool
poolFee: constant(uint256) = 3000

# Parameter in mint function of NonfungiblePositionManager
struct MintParams:
    token0: address
    token1: address
    fee: uint24
    tickLower: int24
    tickUpper: int24
    amount0Desired: uint256
    amount1Desired: uint256
    amount0Min: uint256
    amount1Min: uint256
    recipient: address
    deadline: uint256

# Arguments for SwapRouter to swap tokens
struct ExactInputSingleParams:
    tokenIn: address
    tokenOut: address
    fee: uint24
    recipient: address
    deadline: uint256
    amountIn: uint256
    amountOutMinimum: uint256
    sqrtPriceLimitX96: uint160

# Interface of NonfungiblePositionManager
interface INonfungiblePositionManager:
    def mint(params: MintParams) -> (uint256, uint128, uint256, uint256): payable

interface ISwapRouter:
    def exactInputSingle(params: ExactInputSingleParams) -> uint256: payable

# Interface of WETH
interface IWETH:
    def deposit(): payable

# Event for logging that user has deposited
event Deposit:
    depositor: indexed(address)
    liquidity: uint128
    amount0: uint256
    amount1: uint256

# Event for Swapping
event Swap:
    depositor: indexed(address)
    amount: uint256
    describe: String[100]

# Event to show approve
event TokenApproved:
    target: address
    amount0: uint256
    amount1: uint256

# For testing
@view
@external
def say_hello() -> String[10]:
    return "Hello"

# Deposit with ETH
@payable
@external
def deposit(tickLower: int24, tickUpper: int24):

    assert msg.value > 0, "value can't be zero"

    deadline: uint256 = block.timestamp + 15

    # Swap half amount to USDC
    amount0ToMint: uint256 = ISwapRouter(SwapRouterAddress).exactInputSingle(
        ExactInputSingleParams({
            tokenIn: WETH, 
            tokenOut: USDC, 
            fee: 3000, 
            recipient: self, 
            deadline: deadline, 
            amountIn: msg.value / 2, 
            amountOutMinimum: 0, 
            sqrtPriceLimitX96: 0
        }), 
        value = msg.value / 2)

    log Swap(self, ERC20(USDC).balanceOf(self), "USDC success")
    
    amount1ToMint: uint256 = msg.value / 2

    # Swapt half amount to WETH
    IWETH(WETH).deposit(value = amount1ToMint)

    log Swap(self, ERC20(WETH).balanceOf(self), "WETH success")

    # Approve NonfungiblePositionManger to transfer swapped USDC and WETH
    ERC20(USDC).approve(NonfungiblePositionManagerAddress, amount0ToMint)
    ERC20(WETH).approve(NonfungiblePositionManagerAddress, amount1ToMint)

    #Check allowance
    log TokenApproved(
        NonfungiblePositionManagerAddress, 
        ERC20(USDC).allowance(self, NonfungiblePositionManagerAddress), 
        ERC20(WETH).allowance(self, NonfungiblePositionManagerAddress)
    )

    # Set mint arguments
    params: MintParams = MintParams({
            token0: USDC, 
            token1: WETH, 
            fee: 3000, 
            tickLower: 0, 
            tickUpper: 10000, 
            amount0Desired: amount0ToMint, 
            amount1Desired: amount1ToMint, 
            amount0Min: 0, 
            amount1Min: 0, 
            recipient: msg.sender, 
            deadline: block.timestamp + 100
        })

    # Deposit to USDC-WETH pool with poolFee tier, etc.
    INonfungiblePositionManager(NonfungiblePositionManagerAddress).mint(params)
    
    # Log deposit
    # log Deposit(msg.sender, result.liquidity, result.amount0, result.amount1)

    # # Refund rest USDC to user if it remains
    # if result.amount0 < amount0ToMint:
    #     # Remove allowance of NonfungiblePositionManger from this contract
    #     ERC20(USDC).approve(NonfungiblePositionManagerAddress, 0)
    #     # Rest amount of USDC after deposit
    #     refund0: uint256 = amount0ToMint - result.amount0
    #     # Refund USDC to depositor
    #     ERC20(USDC).transfer(msg.sender, refund0)
    
    # # Refund rest WETH to user if it remains
    # if result.amount0 < amount0ToMint:
    #     # Remove allowance of NonfungiblePositionManger from this contract
    #     ERC20(WETH).approve(NonfungiblePositionManagerAddress, 0)
    #     # Rest amount of USDC after deposit
    #     refund1: uint256 = amount1ToMint - result.amount1
    #     # Refund USDC to depositor
    #     ERC20(WETH).transfer(msg.sender, refund1)

    # return result