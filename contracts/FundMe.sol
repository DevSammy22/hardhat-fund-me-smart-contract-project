// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error FundMe__NotOwner();

/**
 * @title A Sample Funding Contract
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    //State variables
    event Funded(address indexed from, uint256 amount);
    uint256 public constant MINIMUM_USD = 5 * 10**18; //or 50 * 1e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public /*immutable*/ owner;
    AggregatorV3Interface public priceFeed;

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not owner");
        if (msg.sender != owner) {
            revert FundMe__NotOwner();
        } //thi is more gas-efficient
        _; //This means the rest of the code should be executed if the condition above is met;
    }

    constructor(address priceFeedAddress) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    /**
     * @notice This function funds our contract based on the ETH/USD price
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "Didn't send enough! You need to spend more ETH"
        );
        addressToAmountFunded[msg.sender] += msg.value; //We increase the amount once the account is funded
        funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);
        //Below are ways we send or tranfer ether:
        //Transfer
        //payable(msg.sender).transfer(address(this).balance); //It returns nothing. It authomatically revert the amount. "this" keyword means everything in the contract above.

        //Send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance); //It returns bool;
        //require(sendSuccess, "Send failed");

        //Call
        // (bool success, ) = i_owner.call{value: address(this).balance}("");
        // require(success);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Transfer failed");
    }
}
