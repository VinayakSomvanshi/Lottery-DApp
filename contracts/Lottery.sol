pragma solidity ^0.5.16;

contract Lottery {
    struct User {
        address userAddress;
        uint tokensBought;
        uint[] guess;
    }

    mapping (address => User) public users;
    address[] public userAddresses;
    address payable public owner;
    bytes32 winningGuessSha3;

    constructor(uint _winningGuess) public {
        owner = msg.sender;
        winningGuessSha3 = keccak256(abi.encodePacked(_winningGuess));
    }

    function userTokens(address _user) view public returns (uint) {
        return users[_user].tokensBought;
    }

    function userGuesses(address _user) view public returns(uint[] memory) {
        return users[_user].guess;
    }

    function winningGuess() view public returns(bytes32) {
        return winningGuessSha3;
    }

    function makeUser() public {
        users[msg.sender].userAddress = msg.sender;
        users[msg.sender].tokensBought = 0;
        userAddresses.push(msg.sender);
    }

    function addTokens() payable public {
        uint present = 0;
        uint tokensToAdd = msg.value / (10**18);

        for(uint i = 0; i < userAddresses.length; i++) {
            if(userAddresses[i] == msg.sender) {
                present = 1;
                break;
            }
        }

        if (present == 1) {
            users[msg.sender].tokensBought += tokensToAdd;
        }
    }

    function makeGuess(uint _userGuess) public {
        require(_userGuess < 1000000 && users[msg.sender].tokensBought > 0);
        users[msg.sender].guess.push(_userGuess);
        users[msg.sender].tokensBought--;
    }

function closeGame() public view returns(address) {
    require(owner == msg.sender);
    address winner = winnerAddress();
    return winner;
}


function winnerAddress() public view returns(address) {
    for(uint i = 0; i < userAddresses.length; i++) {
        User memory user = users[userAddresses[i]];

        for(uint j = 0; j < user.guess.length; j++) {
            if (keccak256(abi.encodePacked(user.guess[j])) == winningGuessSha3) {
                return user.userAddress;
            }
        }
    }
    return owner;
}


    function getPrice() public returns (uint) {
        require(owner == msg.sender);
        address winner = winnerAddress();
        if (winner == owner) {
            owner.transfer(address(this).balance);
        } else {
            uint toTransfer = address(this).balance / 2;
            address payable winnerPayable = address(uint160(winner)); // Convert winner to address payable
            winnerPayable.transfer(toTransfer);
            owner.transfer(address(this).balance);
        }
        return address(this).balance;
    }
}
