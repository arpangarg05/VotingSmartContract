// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0<0.9.0;

contract Voting{
    address electionCommision;
    address public winner;
    struct Voter{
        string name;
        uint id;
        uint age;
        string gender;
        address voterAddress;
        uint voterId;
        uint voteDone;
    }
    struct Candidate{
        string name;
        string party;
        uint age;
        uint id;
        string gender;
        address candidAddress;
        uint votes;
    }
    uint nextVoterId = 1;
    uint nextCandidId = 1;

    uint startTime;
    uint endTime;

    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidDetails;
    bool stopVoting;

    constructor(){
        electionCommision = msg.sender;
    }

    modifier isVotingOver(){
        require(block.timestamp>endTime || stopVoting == true, "Voting is not over");
        _;
    }
    modifier onlyCommisioner(){
        require(electionCommision==msg.sender,"Not election commissioner");
        _;
    }
    function candidateRegister(
        string calldata _name,
        string calldata _party,
        uint _age,
        string calldata _gender) external {
            require(stopVoting==false,"Voting has ended");
            require(msg.sender!=electionCommision,"Election commision not allowed");
            require(candidateVerification(msg.sender),"Candidate already registered");
            require(_age>=18,"Minors not allowed");
            require(nextCandidId<3,"Max candidates registered");
            candidDetails[nextCandidId] = Candidate(_name,_party,_age,nextCandidId,_gender,msg.sender,0);
            nextCandidId++;

    }
    function candidateVerification(address _person) internal view returns(bool) {
        for(uint i=1;i<nextCandidId;i++){
            if(candidDetails[i].candidAddress == _person){return false;}
        }
        return true;
    }


    function candidateList() public view returns(Candidate[] memory){
        Candidate[] memory arr = new Candidate[](nextCandidId-1);
        for(uint i=1;i<nextCandidId;i++){
            arr[i-1] = candidDetails[i];
        }
        return arr;
    }


    function voterRegister(string calldata _name,uint aadhar ,uint age,string calldata _gender) external returns(uint){
        require(stopVoting==false,"Voting has ended");
        require(voterVerification(msg.sender),"Voter already registered");
        require(age>=18,"Minors not allowed");
        voterDetails[nextVoterId] = Voter(_name,aadhar,age,_gender,msg.sender,nextVoterId,0);
        nextVoterId++;
        return nextVoterId-1;
    }
    
    function voterVerification(address _person) internal view returns(bool){
        for(uint i=1;i<nextVoterId;i++){
            if(voterDetails[i].voterAddress == _person){return false;}
        }
        return true;
    }
    
    function voterList() public view onlyCommisioner() returns(Voter[] memory) {
        Voter[] memory arr = new Voter[](nextVoterId-1);
        for(uint i=1;i<nextVoterId;i++){
            arr[i-1] = voterDetails[i];
        }
        return arr;
    }
    
    function vote(uint _voterId,uint _id) external {
        require(stopVoting==false,"Voting has ended");
        require(voterDetails[_voterId].voterAddress == msg.sender,"Not voter");
        require(voterDetails[_voterId].voteDone == 0,"Vote already casted");
        require(_id>0 && _id<3 && _id<=nextCandidId-1,"Enter a valid candidate");
        //require(startTime!=0,"Time in votings");
        voterDetails[_voterId].voteDone = _id;
        candidDetails[_id].votes+=1;

    }
    function voteTime(uint _startTime,uint _endTime) external onlyCommisioner{}
    function votingStatus() public view returns (string memory){
        if(startTime==0){return "Voting hasn't started";}
        if(stopVoting == true){return "Voting is Stopped";}
        return "Voting is active";
    }
    function results() external onlyCommisioner() returns(string memory){
        if(candidDetails[1].votes>candidDetails[2].votes){
            winner = candidDetails[1].candidAddress;
            return "Candidate 1 won";}
        else{
            winner = candidDetails[2].candidAddress;
            return "Candidate 2 won";}
    }
    function emergency() public onlyCommisioner(){
        stopVoting = true;
    }

}