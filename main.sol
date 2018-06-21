pragma solidity ^0.4.0

contract Central is Election {
        address[] cCandidates;  // Currupted candidates
	mapping (address => uint) score;
	
	address[] distributedContracts;

        //private members
        uint private V_min = 25;        // Minimum number of votes required to generate score
        uint private V_c;       // Mean of votes of top 0.1% or top 10 (whichever is larger) of the candidate
        uint private S_q = 350; // The score assigned to V_min
        uint private S_t = 900; // The score assigned to V_c
        uint private mean;
        uint private sd;        // Mean and standard deviation of all the candidates who got atleast one vote.

	function createContract() {
		Election distributedContract = new Election();
		distributedContracts.push(distributedContract);	
	}

	function generateScore() onlyAfterElectionTime {

                // Generating mean and standard deviation
                uint sum = 0;
                for(uint i= 0; i < candidates.length; i++) {
                        if(STVs[candidates[i]] > 0) {
                                sum += STVs[candidates[i]];
                                cCandidates.push(candidates[i]);
                        }
                }
                mean = sum / cCandidates.length;        // Integral value; float not supported in Solidity
                sum = 0;
                for(i = 0; i < candidates.length; i++) {
                        if(STVs[candidates[i]] > 0) {
                                sum += (STVs[candidates[i]] - mean)**2;
                        }
                }
                sd = sqrt(sum / (cCandidates.length - 1));      //Integral value; float not supported in Solidity

                // Calculating Score of all the candidates who got a vote
                sum = 0;
                V_min = (V_min > mean + sd)?V_min:(mean + sd);
                quickSort(cCandidates, 0, cCandidates.length - 1);
                if(cCandidates.length * 0.1 > 10) {     // Top 10 corruptors
                        for(i = 0; i < cCandidates.length; i++)
                                sum += STVs[cCandidates[i]];
                        V_c = sum / cCandidates.length;
                }
                else if(cCandidates.length >= 10){      // Top 10 corruptors
                        for(i = 0; i < 10; i++)
                                sum += STVs[cCandidates[i]];
                        V_c = sum / cCandidates.length;
                }

                for(i = 0; i < cCandidates.length; i++)
                        score[cCandidates[i]] = S_q + (S_t - S_q)*(STVs[cCandidates[i]] - V_min)/(V_c - V_min);
        }
	 // Mathematical functions
        function sqrt(uint x) internal returns (uint y) {
                uint z = (x + 1) / 2;
                y = x;
                while (z < y) {
                        y = z;
                        z = (x / z + z) / 2;
                }
        }

        function quickSort(address[] storage cCandidates, uint left, uint right) internal {
                uint i = left;
                uint j = right;
                uint pivot = STVs[cCandidates[left + (right - left) / 2]];
                while (i <= j) {
                        while (STVs[cCandidates[i]] < pivot) i++;
                        while (pivot < STVs[cCandidates[j]]) j--;
                        if (i <= j) {
                                (cCandidates[i], cCandidates[j]) = (cCandidates[j], cCandidates[i]);
                                i++;
                                j--;
                        }
                }
                if (left < j)
                        quickSort(cCandidates, left, j);
                if (i < right)
                        quickSort(cCandidates, i, right);
        }

}
