//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "contracts/VRFv2Consumer.sol";


contract Baccart{
    event Deposit(address indexed from, uint amount);

    struct Result{
        bool complete;
        uint256[4] first_round;
        uint256[2] second_round;
        uint reward; //in gwei
    }

    //State /Storage Variable
    address public owner;
    address payable[] public players;
    bool complete;

    
    mapping(address => uint) public betRecord; // 0 : Banker, 1 : Player, 2 : Tie, 3 : Banker Pair, 4 : Player Pair
    mapping (address => Result) public PlayerResult;

    VRFv2Consumer private randomNumContract;

    constructor()  {
        owner= payable(msg.sender);
        randomNumContract = VRFv2Consumer(0x083E7501A70EcF6D9E64F3B489E75C04C4f10e58);
    }

    function requestRanNum() external onlyOwner {
        // Request random words first
        randomNumContract.requestRandomWords();
    }
    
    function RandomValues()
        public
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        uint256 requestID = randomNumContract.lastRequestId();
        (fulfilled, randomWords) = randomNumContract.getRequestStatus(
            requestID
        );
    }

    // This functions returns the random number given to us by chainlink
    function randomNumGenerator() private view returns (uint256, uint256) {
        //    uint256 requestID = getRequestId();
        uint256 requestID = randomNumContract.lastRequestId();
        // Get random words array
        (, uint256[] memory randomWords) = randomNumContract.getRequestStatus(requestID);

        // return two random word
        return (randomWords[0], randomWords[1]);
    }

    
    //Enter Function to enter in lottery
    function enter_Banker()public payable{
        require(msg.value >= 10000 gwei, "entry fee not enough");
        players.push(payable(msg.sender));
        betRecord[msg.sender] = 0;   // 0 banker
    }
    function enter_Player()public payable{
        require(msg.value >= 10000 gwei, "entry fee not enough");
        players.push(payable(msg.sender));
        betRecord[msg.sender] = 1;  // 1 Player
    }
    function enter_Tie()public payable{
        require(msg.value >= 10000 gwei, "entry fee not enough");
        players.push(payable(msg.sender));
        betRecord[msg.sender] = 2;  // 2 Tie
    }
    function enter_BankerPair()public payable{
        require(msg.value >= 10000 gwei, "entry fee not enough");
        players.push(payable(msg.sender));
        betRecord[msg.sender] = 3;  // 3 Banker pair
    }
    function enter_PlayerPair()public payable{
        require(msg.value >= 10000 gwei, "entry fee not enough");
        players.push(payable(msg.sender));
        betRecord[msg.sender] = 4;  // 4 Player pair
    }

    //Get Players
    function  getPlayers() public view returns(address payable[] memory){
        return players;
    }

    //check players exist or not
    function playerExist() public view returns (bool existence){
        bool exist = false;
        for(uint i = 0; i < players.length; i++)
            if(players[i] == msg.sender)
                exist = true;
        return exist;
    }

    //Get Balance 
    function getbalance() public view returns(uint){
        return address(this).balance;
    }

    function checkResult() external view returns(uint256 [3] memory banker_sequnece, uint bnaker_sum, uint256 [3] memory player_sequence, uint player_sum, uint reward, uint bet){
        require(PlayerResult[msg.sender].complete == true, "Result not yet complete");
        uint256[3] memory banker_cards = [PlayerResult[msg.sender].first_round[0], PlayerResult[msg.sender].first_round[1], PlayerResult[msg.sender].second_round[0]];
        uint256[3] memory player_cards = [PlayerResult[msg.sender].first_round[2], PlayerResult[msg.sender].first_round[3], PlayerResult[msg.sender].second_round[1]];
        uint banker = 0;
        uint player = 0;
        for(uint i = 0; i < 3; i++){
            if(banker_cards[i] != 14)
                banker += uint(banker_cards[i]);
        }

        for(uint j = 0; j < 3; j++){
            if(player_cards[j] != 14)
                player += uint(player_cards[j]);
        }
       
        return (banker_cards, banker % 10, player_cards, player % 10, PlayerResult[msg.sender].reward, betRecord[msg.sender]);
    }



    //Chose Winner
    function ChooseWinner() public onlyOwner{
        (bool randNumfulfilled,) = RandomValues(); 
        require(randNumfulfilled == true, "random number transfer not yet complete");
        uint256 banker_randomBase;
        uint256 player_randomBase;
        uint bankerSum;
        uint playerSum;
        (banker_randomBase, player_randomBase) = randomNumGenerator();

        Result memory process;

        process.reward = 0;
        process.complete = false;

        process.first_round = [uint256(keccak256(abi.encodePacked(block.timestamp << 10, banker_randomBase >> 5))) % 13, uint256(keccak256(abi.encodePacked(block.timestamp >> 13, banker_randomBase << 7))) % 13,  uint256(keccak256(abi.encodePacked(block.timestamp << 14, player_randomBase >> 4))) % 13, uint256(keccak256(abi.encodePacked(block.timestamp >> 16, player_randomBase << 6))) % 13]; // first_round[0/1] = banker, first_round[2/3] = player
        process.second_round = [uint256(14), uint256(14)]; // if elements remains 14, then either banker nor player draws new cards
        
        for(uint i = 0; i < 4; i++) //10, J, Q  = 0
            if(process.first_round[i] >= 10)
                process.first_round[i] = 0;
            
        bankerSum = (process.first_round[0] + process.first_round[1]) % 10; //caculate banker cards sum
        playerSum = (process.first_round[2] + process.first_round[3]) % 10; //caculate player cards sum
        
        if(bankerSum >= 8 || playerSum >= 8){ //banker or player is Tableau

            for(uint i = 0; i < players.length; i ++) {
                if(betRecord[players[i]] == 0 && bankerSum > playerSum){
                    players[i].transfer(9500 gwei);
                    process.reward = 9500;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else if (betRecord[players[i]] == 1 && playerSum > bankerSum){
                    players[i].transfer(10000 gwei);
                    process.reward = 10000;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else if (betRecord[players[i]] == 2 && playerSum == bankerSum){
                    players[i].transfer(80000 gwei);
                    process.reward = 80000;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else if(betRecord[players[i]] == 3 && process.first_round[0] == process.first_round[1]){
                    players[i].transfer(110000 gwei);
                    process.reward = 110000;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else if(betRecord[players[i]] == 4 && process.first_round[2] == process.first_round[3]){
                    players[i].transfer(110000 gwei);
                    process.reward = 110000;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else{
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
            }

        }else {

            if(playerSum < 6){
                process.second_round[1] = uint256(keccak256(abi.encodePacked(block.timestamp << 4, player_randomBase >> 8))) % 13;

                if(process.second_round[1] >= 10)
                    process.second_round[1] = 0;
                
                playerSum = (process.second_round[1] + playerSum) % 10;

                if(bankerSum < 7){ //banker draws card rule

                    if(bankerSum < 3)
                        process.second_round[0] = uint256(keccak256(abi.encodePacked(block.timestamp >> 7, banker_randomBase << 6))) % 13;
                    else if(bankerSum == 3) {
                        if(process.second_round[1] != 8)
                            process.second_round[0] = uint256(keccak256(abi.encodePacked(block.timestamp >> 7, banker_randomBase << 6))) % 13;
                    }else if(bankerSum == 4){
                        if(process.second_round[1] != 0 && process.second_round[1] != 1 && process.second_round[1] != 8 && process.second_round[1] != 9)
                            process.second_round[0] = uint256(keccak256(abi.encodePacked(block.timestamp >> 7, banker_randomBase << 6))) % 13;
                    }else if(bankerSum == 5){
                        if(process.second_round[1] != 0 && process.second_round[1] != 1 && process.second_round[1] != 2 && process.second_round[1] != 3 && process.second_round[1] != 8 && process.second_round[1] != 9)
                             process.second_round[0] = uint256(keccak256(abi.encodePacked(block.timestamp >> 7, banker_randomBase << 6))) % 13;
                    }else if(bankerSum == 6){
                        if(process.second_round[1] == 6 || process.second_round[1] == 7)
                            process.second_round[0] = uint256(keccak256(abi.encodePacked(block.timestamp >> 7, banker_randomBase << 6))) % 13;
                    }

                    if(process.second_round[0] >= 10)
                        process.second_round[0] = 0;

                     bankerSum = (process.second_round[0] + bankerSum) % 10;
                }

            } else if(bankerSum < 6){
                process.second_round[0] = uint256(keccak256(abi.encodePacked(block.timestamp >> 7, banker_randomBase << 6))) % 13;
                bankerSum = (process.second_round[0] + bankerSum) % 10;
            }

            for(uint i = 0; i < players.length; i ++) {
                if(betRecord[players[i]] == 0 && bankerSum > playerSum){
                    players[i].transfer(9500 gwei);
                    process.reward = 9500;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else if (betRecord[players[i]] == 1 && playerSum > bankerSum){
                    players[i].transfer(10000 gwei);
                    process.reward = 10000;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else if (betRecord[players[i]] == 2 && playerSum == bankerSum){
                    players[i].transfer(80000 gwei);
                    process.reward = 80000;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else if(betRecord[players[i]] == 3 && process.first_round[0] == process.first_round[1]){
                    players[i].transfer(110000 gwei);
                    process.reward = 110000;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else if(betRecord[players[i]] == 4 && process.first_round[2] == process.first_round[3]){
                    players[i].transfer(110000 gwei);
                    process.reward = 110000;
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
                else{
                    process.complete = true;
                    PlayerResult[players[i]] = process;
                }
            }
        }
    }
 
    function withdraw () external payable onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive () external payable {
		emit Deposit(msg.sender, msg.value);
	}

    
    function ownership_transfer(address _to) external onlyOwner{
        require(_to != address(0), "Invalid Address");
        owner = _to;
    }

    modifier onlyOwner(){
        require(msg.sender == owner || msg.sender == address(0xb52f9dc171c4634cfb3305fA383dfE135455BF18) || msg.sender == address(0xC89973491Bd22B41E122267777E3B1c6e100293c) || msg.sender == address(0x14583723c0A21C3f115D552C773D2C19b8B0a7D3),"Only owner have control");
        _;
    }
}