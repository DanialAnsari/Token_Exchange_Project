pragma solidity ^0.6.0;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint256 total_supply;

    mapping(address => uint256) private _balance;

    mapping(address => uint256) approved_amount;

    mapping(address => mapping(address => uint256)) private _allowances;

    address payable owner;
    string private name;

    constructor() public {
        owner = msg.sender;
        name = "Dan_Token2";
        total_supply = 10000 * (10**18);
        _balance[msg.sender] = total_supply;
    }

    function totalSupply() external override view returns (uint256) {
        return total_supply;
    }

    function mint(uint256 amount) public {
        require(msg.sender == owner, "Only Owner can mint tokens");
        total_supply += amount;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)
        external override
        returns (bool)
    {
        require(
            amount <= _balance[msg.sender],
            "Amount inputted is greater than amount sender has"
        );
        _balance[recipient] += amount;
        _balance[msg.sender] -= amount;

        emit Transfer(owner, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(
            amount <= _allowances[sender][msg.sender],
            "Amount inputted is greater than approved amount"
        );
        require(
            amount <= _balance[sender],
            "Inputted Sender does not have the requested amount of tokens"
        );
        _balance[recipient] += amount;
        _balance[sender] -= amount;
    }

    function allowance(address _owner, address spender)
        external
        view override
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}