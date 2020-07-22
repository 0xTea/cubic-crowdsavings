// SPDX-License-Identifier: MIT

pragma solidity >=0.5.4 <0.7.0;
// Importing OpenZeppelin's SafeMath Implementation
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import '../contracts/Project.sol';

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

