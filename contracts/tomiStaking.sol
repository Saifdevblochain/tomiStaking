// SPDX-License-Identifier: GPL

pragma solidity ^0.8.0;
import "./ABDKMath64x64.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


interface IPioneerNFT{
    function mint(address to) external;
}

interface IMiniPioneerNFT{
    function mint(address to) external;

}
contract tomiStaking is Initializable {
    // variables
    uint public stakesForPioneerDuration;
    uint public timeInSeconds;
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
        uint startTime;
        uint endTime;
       uint stakeAmountPioneer;
       uint stakeDurationPioneer;
       }

    struct StakesInfo{
        uint startTime_;
        uint endTime_;
        uint stakeAmount;
        uint stakeDuration;
        uint stakeAPY;
        }

    // events
    event stakedAPY  (address staker,uint amountStaked, uint stakeTime, uint lockPeriod, uint APY  );
    event stakedForPioneer (address staker,uint amountStaked, uint stakeTime, uint lockPeriod  );
    event unStakeAPY (address unStaker, uint unStakeTime ,uint unStakeIndex,uint unStakeAmount, uint _reward);
    event unStakeForPioneer(address unStaker, uint unStakeTime ,uint unStakeIndex,uint unStakeAmount);


      function initialize ( IERC20 _tomi , address _pioneerNft , IMiniPioneerNFT _miniPioneer ) public initializer  {

        stakeperiod= [6,12,24];
        stakeApy= [6,8,10];  
        tomiTokenStakesAmount= [180 ether, 18000 ether];
        tomi= _tomi ;
        stakesForPioneerDuration=12;
        PioneerNFT= IPioneerNFT(_pioneerNft);
        MiniPioneerNFT = _miniPioneer;
        timeInSeconds = 60;
    }

   function setPioneerNFT(IPioneerNFT PioneerNFT_) public {
    PioneerNFT=PioneerNFT_;
   }

   function setMiniPioneerNFT(IMiniPioneerNFT MiniPioneerNFT_) public {
    MiniPioneerNFT=MiniPioneerNFT_;
   }

   function settimeInSeconds(uint timeInSeconds_) public {
    timeInSeconds= timeInSeconds_;
   }

    function stakeForAPY(uint principalAmount_ , uint type_) public {
        require(type_>=0 && type_<=2 );
        SafeERC20.safeTransferFrom( tomi, msg.sender, address(this), principalAmount_);
        stakes[msg.sender][stakerindex[msg.sender]].stakeAmount = principalAmount_;  
        stakes[msg.sender][stakerindex[msg.sender]].stakeDuration = stakeperiod[type_]; 
        stakes[msg.sender][stakerindex[msg.sender]].startTime_ = block.timestamp;
        stakes[msg.sender][stakerindex[msg.sender]].endTime_ = block.timestamp + stakeperiod[type_] * timeInSeconds ;

        stakes[msg.sender][stakerindex[msg.sender]].stakeAPY =stakeApy[type_];


        stakerindex[msg.sender]++;
        
        emit stakedAPY (msg.sender, principalAmount_, block.timestamp,stakeperiod[type_], stakeApy[type_] );
    }

    function stakeForPioneer(uint amountToStake ) public {
        require(amountToStake>=0 && amountToStake<=1 );
        SafeERC20.safeTransferFrom( tomi, msg.sender, address(this), tomiTokenStakesAmount[amountToStake]);
        stakesForPioneer[msg.sender][stakerIndexPioneer[msg.sender]].stakeAmountPioneer =tomiTokenStakesAmount[amountToStake];  
        stakesForPioneer[msg.sender][stakerIndexPioneer[msg.sender]].stakeDurationPioneer =stakesForPioneerDuration; //chjange to var
        stakesForPioneer[msg.sender][stakerIndexPioneer[msg.sender]].startTime = block.timestamp ; 
        stakesForPioneer[msg.sender][stakerIndexPioneer[msg.sender]].endTime = block.timestamp + (stakesForPioneerDuration * timeInSeconds); 
        
        stakerIndexPioneer[msg.sender]++;
       
        amountToStake == 0 ? MiniPioneerNFT.mint(msg.sender) : PioneerNFT.mint(msg.sender);
        
        emit stakedForPioneer(msg.sender,tomiTokenStakesAmount[amountToStake], block.timestamp,12  );
    }

    
    function unStakeWithAPY ( uint indexUnstake ) public {
        require(stakerindex[msg.sender] > 0, "No Stakes : APY");
        require(block.timestamp >= stakes[msg.sender][indexUnstake].endTime_, "LockPeriod not over");

        uint reward= _calculateAPY(indexUnstake);

        // tomi.mint(msg.sender, reward);
        SafeERC20.safeTransfer(tomi, msg.sender, stakes[msg.sender][indexUnstake].stakeAmount);

        delete stakes[msg.sender][indexUnstake];
        emit unStakeAPY( msg.sender,  block.timestamp,indexUnstake, stakes[msg.sender][indexUnstake].stakeAmount, reward);

    }

    function unStake(uint indexToUnstake) public {
        require(stakerIndexPioneer[msg.sender] > 0, "No Stakes");
        require(block.timestamp>= stakesForPioneer[msg.sender][indexToUnstake].endTime, "LockPeriod not over");
        uint _amount= stakesForPioneer[msg.sender][indexToUnstake].stakeAmountPioneer;
        SafeERC20.safeTransfer(tomi, msg.sender, _amount);
        // revert if amount zero 
        delete stakesForPioneer[msg.sender][indexToUnstake];
        emit unStakeForPioneer( msg.sender,  block.timestamp,indexToUnstake, _amount );
    }

 
    
    function setTomi(IERC20 _tomi) public {
        tomi= _tomi;
    }   


    
    function _calculateAPY(uint index ) internal view returns (uint256) {
    if ( stakes[msg.sender][index].stakeDuration == 0) {
        return 0;
    }
    uint256 accruedAmount = ABDKMath64x64.mulu(
        ABDKMath64x64.pow(
            ABDKMath64x64.add(
                ABDKMath64x64.fromUInt(1), ABDKMath64x64.divu( ((stakes[msg.sender][index].stakeAPY*10**18/100)/stakeperiod[index]),10**18)),
            stakes[msg.sender][index].stakeDuration),
            stakes[msg.sender][index].stakeAmount
    );

    // use accruedAmount if total value is needed
    uint256 reward = accruedAmount - stakes[msg.sender][index].stakeAmount;
    
    return reward;
    }


    function calculateReward(uint index ) public view returns (uint256) {
       
    if ( stakes[msg.sender][index].stakeDuration == 0) {
        return 0;
    }
    uint256 endTime = block.timestamp > stakes[msg.sender][index].endTime_ ? stakes[msg.sender][index].endTime_ : block.timestamp;
    uint256 numOfmonths = (endTime - stakes[msg.sender][index].startTime_) / timeInSeconds;
    uint256 accruedAmount = ABDKMath64x64.mulu(
        ABDKMath64x64.pow(
            ABDKMath64x64.add(
                ABDKMath64x64.fromUInt(1), ABDKMath64x64.divu( ((stakes[msg.sender][index].stakeAPY*10**18/100)/stakeperiod[index]),10**18)),
                numOfmonths),
         stakes[msg.sender][index].stakeAmount
    );

    // use accruedAmount if total value is needed
    uint256 reward = accruedAmount - stakes[msg.sender][index].stakeAmount;
    
    return reward;
    }

    // // function calculateReward(uint index) public {
    //     // start time+ 1month*6 

    //     // block.timestamp- startTime

    //     // uint256 numOfmonths = (currentTime - staking.startTime) / one monthinseconds;
    //     // put numOfmonths in exponential;

    // }

   

}

// create a separate variable for that mul, div/div

// create a function for getting rewards to show on the fronetnd 
// 


// emit nft id on mint