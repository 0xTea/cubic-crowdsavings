// SPDX-License-Identifier: MIT

pragma solidity >=0.5.4 <0.7.0;
// Importing OpenZeppelin's SafeMath Implementation
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

import "./Project.sol";
/** @title CrowdSaving */
contract CrowdSaving {
    using SafeMath for uint256;

    // List of existing projects (Contract Objects)
    uint public numOfProjects;

    mapping (uint => address) public projects;
    // Event that will be emitted whenever a new project is started
    event ProjectStarted(
        address contractAddress,
        address projectStarter,
        string  projectTitle,
        string  projectDesc,
        uint256 distributedAmount,
        int   contributorsCount,
        uint256 deadline,
        uint256 goalAmount
    );
    
    event LogFailure(string message);
    event ProjectJoined(int message);

    /** @dev Function to start a new project.
      * @param title Title of the project to be created
      * @param description Brief description about the project
      * @param durationInDays Project deadline in days
      * @param amountToRaise Project goal in wei
      */
       function startProject(
        string  calldata title,
        string  calldata description,
        int  numberContributors,
        uint durationInDays,
        uint amountToRaise
        ) external  payable returns (address projectAddress)  {
            uint raiseUntil = durationInDays;
            Project newProject = new Project(msg.sender, title, description,numberContributors, raiseUntil, amountToRaise);
            projects[numOfProjects] = address(newProject);
            numOfProjects++;
            emit ProjectStarted(address(newProject),
                msg.sender,
                title,
                description,
                newProject.distributedAmount(),
                numberContributors,
                raiseUntil,
                amountToRaise
                );
            return address(newProject);
    }
    
      function joinProject(address _projectAddress) public returns (bool successful) { 
            Project deployedProject = Project(_projectAddress);
            if (deployedProject.fundingHub() == address(0)) {
                emit LogFailure("Project contract not found at address");
            }
             deployedProject.join(msg.sender);
             emit ProjectJoined(deployedProject.contributorsCount());
             return true;
      }
      
      function contribute(address _projectAddress) public payable returns (bool successful) { 
            Project deployedProject = Project(_projectAddress);
            if (deployedProject.fundingHub() == address(0)) {
                emit LogFailure("Project contract not found at address");
            }
             deployedProject.contribute{value:msg.value}(msg.sender);
             return true;
         }
}