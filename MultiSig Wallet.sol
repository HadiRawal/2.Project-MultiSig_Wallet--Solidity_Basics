// *** 2.Project: Multi signatures Wallet, it is the final sequence of  Solidity Basics *** //
/******** Multi signatures Wallet ********/
//built on remix.ethereum.org
//Multi signatures wallet: a wallet requires a certain limit of signatures(approvals) from the owners in order to do fund transfer.

pragma solidity 0.7.5;
pragma abicoder v2; //In order to return struct from function

contract Wallet {
//Variables:
    address[] public owners; //array of addresses for the Owner that we need their signatures
    uint limit; // number of the signatures to verify the transaction(transfer)
    
    struct Transfer{
        uint amount;
        address payable receiver;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }
    
    Transfer[] transferRequests; //array of Transfer structs
    
    mapping(address => mapping(uint => bool)) approvals; //double mapping to record the approvals

//Events:
    // Events are recording (archiving) function actions in events log
    //1. Recording the transfer requests that have created.
    event TransferRequestCreated(uint _id, uint _amount, address _initiator, address _receiver);
    //2. Recording the approvals that have been receied.
    event ApprovalReceived(uint _id, uint _approvals, address _approver);
    //3. Recording the transfers that have been approved.
    event TransferApproved(uint _id);    

//Modifier (Function Type Creator):
    /*Modifier to create tag with specific features(restrictions / permissions),
    then we can add it to the header of the function. 
    the function with the modifier will follow the restriction when it is being excuted.*/
    //here we need modifier to restrict fund transferring only to owners.
    
    modifier onlyOwner(){
        bool owner = false;
        for(uint i=0; i<owners.length;i++){ //checking the msg.sender with list of owners
            if(owners[i] == msg.sender){ //if it is an owner, return true
                owner = true;
            }
        }
        require(owner == true); //owner should true in order to continue with function execution
        _;
    }
//Constructor (Variables Initializer): -one time when deploying the contract-
    /*Constructor to identify(initialize) the owners and the required limit of signatures.
      will be executed one time when we deploy the contract*/
    constructor(address[] memory _owners, uint _limit) { 
    owners = _owners;
    limit = _limit;
    }

//Functions:
    //**Deposit Function//
    function deposit() public payable{} //no conditions and restrictions for deposition (ordinary function)

    //**Transfer Request Creating Function //
    //create an instance of the Transfer struct and add it to the transferRequests array
    function createTransfer (uint _amount, address payable _receiver) public onlyOwner{
        emit TransferRequestCreated (transferRequests.length, _amount, msg.sender, _receiver); //Calling TransferRequestCreated Event.
        transferRequests.push(Transfer(_amount, _receiver, 0, false, transferRequests.length));
    }
    
    //**Approving Procedure Function //
    function approve(uint _id) public onlyOwner {
        //I. Check Fundamental Conditions: 
        /*******************************/
            //1.(Condition 1) an owner should not be able to vote twice:
            require(approvals[msg.sender][_id] == false);
            //2.(Condition 2) an owner should not be able to vote on a transfer request that has already been sent:
            require(transferRequests[_id].hasBeenSent == false);
        
        //II. Adding Approval to the list:
        /*****************************/
            //1. Mark this approval as true
            approvals[msg.sender][_id] = true;
            //2. Increasing the total of approvals
            transferRequests[_id].approvals++;
        
        emit ApprovalReceived(_id, transferRequests[_id].approvals, msg.sender); //Calling ApprovalReceived Event.

        
        //III. Conditional Statement: to know if we hit the target or not.
        /*****************************************************************/
            //Check if we reached the limit of approvals in order to do transfer
            if(transferRequests[_id].approvals >= limit){
                //1. Mark the Transfer Request as Sent(true)
                transferRequests[_id].hasBeenSent = true;
                //2. Execute the Transaction
                transferRequests[_id].receiver.transfer(transferRequests[_id].amount);
                emit TransferApproved(_id); //Calling TransferApproved Event.
            }
    }
    
    //**Requests-Viewing Function //
    //Showing all transfer requests: 
    function getTransferRequests() public view returns (Transfer[] memory){
        return transferRequests;
    }
    
}

/*RUN the Contract (Deploying)
*Setting the constructor befor deploying the contract: 
_OWNERS: == e.g. ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
_LIMIT: == e.g. 2 */ 

