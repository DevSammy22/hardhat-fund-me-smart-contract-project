// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
//import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
error NotOwner();

contract FundMe{
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18; //or 50 * 1e18;
    //constant and immutable are gas optimiation tools
    //The difference between constant and immutable is that:
    //Constant can not be changed once declared and also, it is assigned once declared
    //Immutable can be changed, and can be declared and afterwards assigned
    //21,425 gas - constant
    //23,515 gas - non-constant
    //21,415 * 141000000000 = $9.058545
    //23,515 * 141000000000 = $9.946845

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public /* immutable */ i_owner; //i_owner - the style of names shows that the variable is immutable //This is to set the owner of the contract
    //21,508 gas - immutable
    //23,644 gas - non-immutable

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable{
        //Want to be able to set a minimum fund amount in USD
        //We converted ethereum to usd as shown below (this is possible using chainlink and oracle)
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!"); //1e18 == 1*10**18
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value; //We increase the amount once the account is funded
        //msg.value(uint) indicates how much ETH or blockchain currency we send i.e the number of wei sent with the message
        //msg.sender(address) indicates the address of the sender
        //keyword payable makes fund function red.
        //msg.value and msg.callvalue can only be used in payable public functions
        //Money math is done in terms of wei, So 1ETH needs to be set as 1e18 value
    }

   // function getPrice() public view returns(uint256) {
    //     //To consume price data, your smart contract should reference AggregatorV3Interface;
    //     //We need: 1. ABI (To get the ABI, we need the interface)
    //     //2. Address(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e)/
    //     //To interact with another external or internal contract ABI and address.
    //     //In this case we need to reference AggregatorV3Interface which is a function under contract PriceConsumerV3
    //     //In oder word, to achieve interface, we need ABI and address as shown below
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    //     (,int256 price,,,) = priceFeed.latestRoundData();
    //     //ETH in terms of USD
    //     return uint256(price * 1e10); //This is type-casting. //1**10 == 10000000000
    // }

    // function getVersion() public view returns(uint256){
    //     // ETH/USD price feed address of Goerli Network.
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    //     return priceFeed.version();
    // }
 
    // function getConversionRate(uint256 ethAmount) public view returns (uint256){
    //     uint256 ethPrice = getPrice();
    //     uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; //We are dividing by 1e18 because ethPrice * ethAmount would give us 1e36
    //     return ethAmountInUsd;
    // }

    function withdraw() public onlyOwner {
        for(uint256 i = 0; i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);
        //Below are ways we send or tranfer ether:
        //Transfer
        //payable(msg.sender).transfer(address(this).balance); //It returns nothing. It authomatically revert the amountthis keyword means everything in the contract above.
        //Send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance); //It returns bool;
        //require(sendSuccess, "Send failed");
        //Call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    
    modifier onlyOwner{
        //require(msg.sender == i_owner, "Sender is not owner");
        if(msg.sender != i_owner){
            revert NotOwner();
        } //thi is more gas-efficient
        _; //This means the rest of the code should be executed if the condition above is met;
    }

    //What happens if someone sends this contract ETH without calling the fund function
    receive() external payable{
        fund();
    }
    fallback() external payable{
        fund();
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()
}

//In the deploy plugin, the withdraw is orange because we are not paying (i.e it is not a payable function)
//Fund is red because it is a payable function.