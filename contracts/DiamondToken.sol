// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf() external view returns (uint256);

    function approvedRepBal(
        address owner,
        address spender
    ) external view returns (uint256);

    function transferTokens(
        address _to,
        uint256 amount
    ) external returns (bool);

    function approveRep(address rep, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DiamondToken is IERC20 {
    uint8 public constant decimals = 18;
    string public symbol = "DND";
    string public tokenName = "Diamond";
    uint256 _totalSupply = 1000 * 1e18;

    struct TransferDetails {
        uint256 amount; // amount sent
        bool status; // status of transaction
        address _to; // person tokens was send to
        uint256 time; // time tokens was send to
    }

    // 3rd Parties
    struct RepDetails {
        uint256 balance; // amount sent
        address _rep; // person tokens was send to
    }

    // A dynamically-sized array of `Transaction` structs.
    TransferDetails[] public transferHistory;
    RepDetails[] public repsList;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        balances[msg.sender] = _totalSupply;
    }

    // get total supply of token
    function totalSupply() public view returns (uint256 total) {
        total = _totalSupply;
    }

    // get balance of contract caller
    function balanceOf() public view returns (uint256 balance) {
        balance = balances[msg.sender];
    }

    // transfer tokens
    function transferTokens(address _to, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient Funds");
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[_to] = balances[_to] + amount;

        // add transaction to history
        transferHistory.push(
            TransferDetails({
                amount: amount,
                _to: _to,
                status: true,
                time: block.timestamp
            })
        );

        emit Transfer(msg.sender, _to, amount);
        return true;
    }

    // assign another person to carry out transaction on your behalf
    function approveRep(address rep, uint256 amount) public returns (bool) {
        allowed[msg.sender][rep] = amount;

        // add rep to list
        repsList.push(RepDetails({balance: amount, _rep: rep}));
        emit Approval(msg.sender, rep, amount);
        return true;
    }

    //assigned rep balance
    function approvedRepBal(
        address _owner,
        address _rep
    ) public view returns (uint bal) {
        bal = allowed[_owner][_rep];
    }

    // transfer tokens on another person behalf
    function transferFrom(
        address owner,
        address buyer,
        uint256 amount
    ) public returns (bool) {
        require(amount <= balances[owner], "Insufficient Funds");
        require(
            amount <= allowed[owner][msg.sender],
            "Please Request for more funds from the owner"
        );

        balances[owner] = balances[owner] - amount;
        allowed[owner][msg.sender] = allowed[owner][msg.sender] - amount;
        balances[buyer] = balances[buyer] + amount;

        // add transaction to history
        transferHistory.push(
            TransferDetails({
                amount: amount,
                _to: buyer,
                status: true,
                time: block.timestamp
            })
        );

        emit Transfer(owner, buyer, amount);
        return true;
    }

    // return Transfer History
    function totalHistory() public view returns (TransferDetails[] memory) {
        return transferHistory;
    }

    // return Reps List
    function totalReps() public view returns (RepDetails[] memory) {
        return repsList;
    }
}
