// SPDX-License-Identifier: MIT

pragma solidity >=0.5.4 <0.7.0;
// Importing OpenZeppelin's SafeMath Implementation
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

/** @title CrowdSaving */
contract CrowdSaving {
    using SafeMath for uint256;

    // List of existing projects (Contract Objects)
    Project[] private projects;

    // Event that will be emitted whenever a new project is started
    event ProjectStarted(
        address contractAddress,
        address projectStarter,
        string projectTitle,
        string projectDesc,
        uint256 distributedAmount,
        int   contributorsCount,
        uint256 deadline,
        uint256 goalAmount
    );

    /** @dev Function to start a new project.
      * @param title Title of the project to be created
      * @param description Brief description about the project
      * @param durationInDays Project deadline in days
      * @param amountToRaise Project goal in wei
      */
    function startProject(
        string calldata title,
        string calldata description,
        int  numberContributors,
        uint durationInDays,
        uint amountToRaise
        ) external {
        uint raiseUntil = now.add(durationInDays.mul(1 days));
        Project newProject = new Project(msg.sender, title, description,numberContributors, raiseUntil, amountToRaise);
        projects.push(newProject);
        
        emit ProjectStarted(
            address(newProject),
            msg.sender,
            title,
            description,
            newProject.distributedAmount(),
            numberContributors,
            raiseUntil,
            amountToRaise
        );
    }                                                                                                                                   

    /** @dev Function to get all projects' contract addresses.
      * @return A list of all projects' contract addreses
      */
    function returnAllProjects() external view returns(Project[] memory){
        return projects;
    }
}

/** @title Project */
contract Project {
    using SafeMath for uint256;
    
    // Data structures
    enum State {
        Fundraising,
        Crowding,
        Expired,
        Successful
    }
    
    // State variables
    address payable public creator;
    uint public amountGoal; // required to reach at least this much, else everyone gets refund

    int public numberContributors;
    uint256 public distributedAmount;
    uint public completeAt;
    uint256 public currentBalance;
    uint public raiseBy;
    address[] public contributors;
    int contributorsCount  = 0;
    string public title;
    string public description;
    State public state = State.Crowding; // initialize on create
    
    mapping (address => uint) public contributions;

    mapping (address => int) public contributions_count; //mapping of address and contribution count

    // Event that will be emitted whenever funding will be received
    event FundingReceived(address contributor, uint amount, uint currentTotal);
    // Event that will be emitted whenever the project starter has received the funds
    event CreatorPaid(address recipient);

    // Modifier to check current state
    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    // // Modifier to check if the function caller is the project creator
    // modifier isCreator() {
    //     require(msg.sender == creator);
    //     _;
    // }

    constructor
    (
        address payable projectStarter,
        string memory projectTitle,
        string memory projectDesc,
        int   projectnumberContributors,
        uint fundRaisingDeadline,
        uint goalAmount
    ) public {
        creator = projectStarter;
        title = projectTitle;
        description = projectDesc;
        amountGoal = goalAmount;
        raiseBy = fundRaisingDeadline;
        currentBalance = 0;
        numberContributors = projectnumberContributors;
        distributedAmount = amountGoal / uint(numberContributors);
        contributors = new address[](uint256(projectnumberContributors));
    }

    
    /** @dev Function to join a certain project limited to contributors.
      */
    function join () external inState(State.Crowding){
        require(msg.sender != creator,'cannot  join as project owner');
        require(contributorsCount <= numberContributors,'Max number of contributors has been met for project');
        if(contributorsCount <= numberContributors){
            contributors[uint256(contributorsCount)] = msg.sender;
            contributorsCount++;
            contributions_count[msg.sender] = 0;// initialize contribtions count to zero
        } else {
            state = State.Fundraising;
        }
    }

    /** @dev Function to fund a certain project.
      */
    function contribute() external inState(State.Fundraising) payable {
        require(distributedAmount == msg.value,'contribution must match distributed amount');
        require(contributions_count[msg.sender] >= 5,'reached max number of contributions');
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        contributions_count[msg.sender] = contributions_count[msg.sender] + 1;
        currentBalance = currentBalance.add(msg.value);
        emit FundingReceived(msg.sender, msg.value, currentBalance);
        checkIfFundingCompleteOrExpired();
    }

    /** @dev Function to change the project state depending on conditions.
      */
    function checkIfFundingCompleteOrExpired() public {
        if (currentBalance >= amountGoal) {
            state = State.Successful;
            payOut();
        } else if (now > raiseBy)  {
            state = State.Expired;
        }
        completeAt = now;
    }

    /** @dev Function to give the received funds to project starter.
      */
    function payOut() internal inState(State.Successful) returns (bool) {
        uint256 totalRaised = currentBalance;
        currentBalance = 0;

        if (creator.send(totalRaised)) {
            emit CreatorPaid(creator);
            return true;
        } else {
            currentBalance = totalRaised;
            state = State.Successful;
        }

        return false;
        
    }

    /** @dev Function to retrieve donated amount when a project expires.
      */
    function getRefund() public inState(State.Expired) returns (bool) {
        require(contributions[msg.sender] > 0);

        uint amountToRefund = contributions[msg.sender];
        contributions[msg.sender] = 0;

        if (!msg.sender.send(amountToRefund)) {
            contributions[msg.sender] = amountToRefund;
            return false;
        } else {
            currentBalance = currentBalance.sub(amountToRefund);
        }

        return true;
    }

    function getDetails() public view returns 
    (
        address payable projectStarter,
        string memory projectTitle,
        string memory projectDesc,
        uint256 deadline,
        State currentState,
        uint256 currentAmount,
        uint256 goalAmount
    ) {
        projectStarter = creator;
        projectTitle = title;
        projectDesc = description;
        deadline = raiseBy;
        currentState = state;
        currentAmount = currentBalance;
        goalAmount = amountGoal;
    }
}