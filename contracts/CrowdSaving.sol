// SPDX-License-Identifier: MIT

pragma solidity >=0.5.4 <0.7.0;

// Importing OpenZeppelin's SafeMath Implementation
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

import "./Project.sol";
import "./ICrowdSaving.sol";

/** @title CrowdSaving */
contract CrowdSaving is ICrowdSaving {
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
   
  function startProject (
        string  memory title,
        string  memory description,
        int  numberContributors,
        uint durationInDays,
        uint amountToRaise
        ) public payable  override returns (address projectAddress)  {
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
        // function utterance() public override returns (bytes32) { return "miaow"; }
      function joinProject(address _projectAddress) public override returns (bool successful) { 
            Project deployedProject = Project(_projectAddress);
            if (deployedProject.fundingHub() == address(0)) {
                emit LogFailure("Project contract not found at address");
            }
             deployedProject.join(msg.sender);
             emit ProjectJoined(deployedProject.contributorsCount());
             return true;
      }
      
      function contribute(address _projectAddress) public payable override returns (bool successful) { 
            Project deployedProject = Project(_projectAddress);
            if (deployedProject.fundingHub() == address(0)) {
                emit LogFailure("Project contract not found at address");
            }
             deployedProject.contribute{value:msg.value}(msg.sender);
             return true;
         }
    }
}