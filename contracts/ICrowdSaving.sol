// SPDX-License-Identifier: MIT
pragma solidity >=0.5.4 <0.7.0;

interface ICrowdSaving {

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
        ) external  payable returns (address projectAddress);
    function joinProject(address _projectAddress) external returns (bool successful);
    function contribute(address _projectAddress) external payable returns (bool successful);
}
