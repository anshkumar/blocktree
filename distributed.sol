pragma solidity ^0.4.0;

contract Election {
	address electionAuthority;
	uint electionEndTime;
	address[] candidates;	// Registered candidates
	mapping (address => uint) STVs;	// Candidate address to number of single transferable votes
	mapping (address => bool) voters;	//Registered voters
	mapping (address => mapping (address => bool) ) hasVoted;	//If a registered voter has voted or not
 
	function Election() {
		electionAuthority = msg.sender;
	}

	modifier onlyElectionAuthority() {
		require(msg.sender == electionAuthority);
		_;
	}

	modifier onlyRegisteredVoters() {
		require(voters[msg.sender]);
		_;
	}

	modifier voteOnlyOnce(address _candidate) {
		require(!hasVoted[msg.sender][_candidate]);
		_;
	}

	modifier onlyDuringElectionTime() {
		require(electionEndTime != 0 || electionEndTime <  block.timestamp);	// 0 can be replaced by the minimum duration of election
		_;
	}

	modifier onlyAfterElectionTime() {
		require(electionEndTime != 0 || electionEndTime > block.timestamp);
		_;
	}

	function startElection(uint duration) onlyElectionAuthority {
		electionEndTime = block.timestamp + duration; 
	}

	function registerCandidate (address _candidate) onlyElectionAuthority {
		candidates.push(_candidate);
	}

	function registerVoter(address voter) onlyElectionAuthority {
		voters[voter] = true;
	}

	function vote(address _candidate) onlyRegisteredVoters voteOnlyOnce(_candidate) onlyDuringElectionTime {
		STVs[_candidate] += 1;
		hasVoted[msg.sender][_candidate] = true;
	}

	function getNumberOfCandidates() constant returns(uint) {
		return candidates.length;
	}

	function getCandidate(uint i) constant returns(address _candidate, uint _STVs) {
		_candidate = candidates[i];
		_STVs = STVs[_candidate];
	}
}
