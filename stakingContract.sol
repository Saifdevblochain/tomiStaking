// SPDX-License-Identifier: GPL

pragma solidity ^0.8.0;
import "./ABDKMath64x64.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPioneerNFT{
    function mintPioneer(address to) external;
}

interface IMiniPioneerNFT{
    function mintMiniPioneer(address to) external;

}

contract APY{
    // variables
    uint public lockPeriod;
    uint[] public stakeperiod;
    uint[] public stakeApy;
    uint[] public tomiTokenStakesAmount;
    //interfaces
    IERC20 public tomi;
    IPioneerNFT public PioneerNFT;
    IMiniPioneerNFT public MiniPioneerNFT;

    //mapppings & struct
    mapping (address=> mapping(uint => StakesInfo)) public stakes;
    mapping(address=> uint ) public stakerindex;
    mapping (address=> mapping(uint => StakesInfoForPioneer)) public stakesForPioneer;
    mapping(address=> uint ) public stakerIndexPioneer;

    struct StakesInfoForPioneer{
       uint stakeAmountPioneer;
       uint stakeDurationPioneer;
       }

    struct StakesInfo{
        uint stakeAmount;
        uint stakeDuration;
        uint stakeAPY;
        }
        
    // events
    event staked(address staker,uint amountStaked, uint stakeTime, uint lockPeriod, uint APY  );
    event stakedForAPY(address staker,uint amountStaked, uint stakeTime, uint lockPeriod  );


   constructor (IERC20 _tomi) {
       stakeperiod= [6,12,24];
       stakeApy= [6,8,10]; // multiply by 10**18
       tomiTokenStakesAmount= [18000 ether, 180 ether];
       tomi= _tomi;
   }

    function stakeForAPY(uint principalAmount_ , uint type_) public {
        require(type_>0 && type_<=2 );
        SafeERC20.safeTransferFrom( tomitoken, msg.sender, address(this), principalAmount_);

        stakes[msg.sender][stakerindex[msg.sender]].stakeAmount =principalAmount_;  
        stakes[msg.sender][stakerindex[msg.sender]].stakeDuration =stakeperiod[type_]; 
        stakes[msg.sender][stakerindex[msg.sender]].stakeAPY =stakeApy[type_];
        stakerindex[msg.sender]++;
        
        emit staked(msg.sender, principalAmount_, block.timestamp,stakeperiod[type_], stakeApy[type_] );
    }

    function stakeForPioneer(uint amounToStake ) public {
        require(amounToStake>0 && amounToStake<=1 );
        SafeERC20.safeTransferFrom( tomitoken, msg.sender, address(this), tomiTokenStakesAmount[amounToStake]);
        stakesForPioneer[msg.sender][stakerIndexPioneer[msg.sender]].stakeAmountPioneer =tomiTokenStakesAmount[amounToStake];  
        stakesForPioneer[msg.sender][stakerIndexPioneer[msg.sender]].stakeDurationPioneer =12; 
        stakerIndexPioneer[msg.sender]++;
        if(amounToStake==0) PioneerNFT.mintPioneer(msg.sender); 
        if(amountStake==1) MiniPioneerNFT.mintMiniPioneer(msg.sender);
        emit stakedForAPY(msg.sender,tomiTokenStakesAmount[amounToStake], block.timestamp,12  );
    }

    
     function unStake(uint indexToUnstake) public {
        require(stakerIndexPioneer[msg.sender] > 0, "No Stakes");
        require(block.timestamp>= stakesForPioneer[msg.sender][indexToUnstake].stakeDurationPioneer, "LockPeriod not over");

        SafeERC20.safeTransfer(tomi, address(this),msg.sender, stakesForPioneer[msg.sender][indexToUnstake].stakeAmountPioneer);
        
        delete stakerIndexPioneer[msg.sender];
        delete stakesForPioneer[msg.sender][indexToUnstake].stakeDurationPioneer=0;
        stakesForPioneer[msg.sender][indexToUnstake].stakeAmountPioneer=0;

        emit unStake( msg.sender,  block.timestamp,  AMOUNTTT );
    }

    // function unStakeWithAPY(){}

    function _calculateAPY(uint indexUnstake ) public  returns (uint256) {
         require(stakerindex[msg.sender] > 0, "No Stakes : APY");
        require(block.timestamp>= stakes[msg.sender][indexUnstake].stakeDuration, "LockPeriod not over");
        if ( stakes[msg.sender][indexUnstake].stakeDuration == 0) {
            return 0;
        }
            uint256 accruedAmount = ABDKMath64x64.mulu(
            ABDKMath64x64.pow(
                ABDKMath64x64.add(
                    ABDKMath64x64.fromUInt(1), ABDKMath64x64.divu( ((stakes[msg.sender][indexUnstake].stakeAPY*10**18/100)/12),10**18)),
                stakes[msg.sender][indexUnstake].stakeDuration),
             stakes[msg.sender][indexUnstake].stakeAmount
        );

        // use accruedAmount if total value is needed
        uint256 reward = accruedAmount - stakes[msg.sender][indexUnstake].stakeAmount;
        delete stakes[msg.sender][indexUnstake];
        return reward;
    }


}


// create a separate variable for that mul, div/div

// create a function for getting rewards to show on the fronetnd 
// 


// how to manage deleting stakingINdex of a single address. because he has staked several time
// now how to remove that specific index ,