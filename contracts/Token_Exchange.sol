pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./Address.sol";
import "./SafeMath.sol";
import "./Initializable.sol";


contract Token_exchange is Initializable{

     uint256 sellid_counter;
     uint256 buyid_counter;
     uint256 negotiate_counter;

    enum PricePaymentOption{
        ETHER,
        TOKEN
    }


    enum Orderstatus{
        FORSALE,
        CLOSED
    }

    enum CounterOrderstatus{
        REJECTED,
        ACCEPTED,
        PENDING,
        CANCELED,
        CLOSED
    }

    struct SellOrder{
        address tokenToSell;
        uint256 amount;
        PricePaymentOption paymentOption;
        uint256 price;
        address tokenToExchange;
        address payable seller;
        uint256 quantity;
        Orderstatus status;
    }

    struct BuyOrder{
        uint256 sellOrderID;
        address buyer;
        
    }

    struct CounterOrder{
        uint256 sellOrderID;
        uint256 price;
        address payable buyer;
        string comment;
        CounterOrderstatus status;
    } 



    mapping(uint256=>SellOrder) public SellOrders;
    mapping(uint256=>CounterOrder) public CounterOrders;
    mapping(uint256=>BuyOrder) public AcceptOrders;

    event SellOrderAltered(uint256 _id,address _tokenToSell , uint256 _amount,uint256 quantity , PricePaymentOption _paymentOption, uint256 _price , address _tokenToExchange , address _seller , Orderstatus _status);

    event AcceptOrderAltered(uint256 _id ,uint256 sell_id, address _buyer);

    event CounterOrderAltered(uint256 id , uint256 sell_id, uint256 _price  , string _comment , CounterOrderstatus _status);


   constructor() public{
         sellid_counter=0;
         buyid_counter=0;
         negotiate_counter=0;
    }


    function registerOrder(address _tokenToSell , uint256 _amount ,uint256 _quantity ,PricePaymentOption _paymentOption, uint256 _price , address _tokenToExchange) external returns(uint256 id){
        require(!Address.isContract(msg.sender),"Seller cannot be a contract");
        SellOrder memory Order;
        Order.tokenToSell=_tokenToSell;
        Order.amount=_amount;
        Order.paymentOption=_paymentOption;
    
    if(_paymentOption==PricePaymentOption.TOKEN){
        Order.tokenToExchange=_tokenToExchange; 
    }
    else{
        Order.tokenToExchange=address(0x0);
    }

        Order.price=_price;
        Order.seller=msg.sender;
        Order.status=Orderstatus.FORSALE;
        Order.quantity=_quantity;
        SellOrders[sellid_counter]=Order;
        IERC20 tokenAddress = IERC20(_tokenToSell);
        
        tokenAddress.transferFrom(msg.sender,address(this),(SafeMath.mul(_amount,_quantity)));

        emit SellOrderAltered(sellid_counter,_tokenToSell , _amount,_quantity , _paymentOption, _price , _tokenToExchange , msg.sender , Order.status);
        sellid_counter=SafeMath.add(sellid_counter,1);

        return (SafeMath.sub(sellid_counter,1));
    }


    function getQuantity(uint256 _sellid) public view returns(uint256){
        return 3;
    }
   
    function recieveAssets(uint256 _sellid) public {
        address seller=SellOrders[_sellid].seller;
        IERC20 tokenToSell=IERC20(SellOrders[_sellid].tokenToSell);
        uint256 amount=SellOrders[_sellid].amount;
        tokenToSell.transfer(msg.sender,amount);

    }

    function buySellOrder(uint256 _sellid ) payable external returns (uint256){
        require(SellOrders[_sellid].status==Orderstatus.FORSALE,"This Sell Order is no longer for sale");
        require(msg.sender!=SellOrders[_sellid].seller,"Seller cannot Accept his own offer");
        require(!Address.isContract(msg.sender),"Offer cannot be accepted by a contract");
        
        uint256 amount;
        if(SellOrders[_sellid].paymentOption==PricePaymentOption.TOKEN){
            
            IERC20 tokenAddress=IERC20(SellOrders[_sellid].tokenToExchange);
            amount= SellOrders[_sellid].price;
            require(tokenAddress.balanceOf(msg.sender)>=amount,"You dont have the funds to buy this token");
            
            tokenAddress.transferFrom(msg.sender,SellOrders[_sellid].seller,amount);
            }
        else{
            amount= SellOrders[_sellid].price;
            require(msg.value==amount,"You dont have the funds to buy this token");
            SellOrders[_sellid].seller.call{value: msg.value}("");
            }
        

        SellOrders[_sellid].quantity=SafeMath.sub(SellOrders[_sellid].quantity,1);
        if(SellOrders[_sellid].quantity<=0){
            SellOrders[_sellid].status=Orderstatus.CLOSED;
        }
        BuyOrder memory Order;
        Order.sellOrderID=_sellid;
        Order.buyer=msg.sender;
        

        AcceptOrders[buyid_counter]=Order;
        emit AcceptOrderAltered(buyid_counter,_sellid , msg.sender);
        buyid_counter=SafeMath.add(buyid_counter,1);

        recieveAssets(_sellid);


        
        emit SellOrderAltered(_sellid,SellOrders[_sellid].tokenToSell , SellOrders[_sellid].amount,SellOrders[_sellid].quantity, SellOrders[_sellid].paymentOption, SellOrders[_sellid].price , SellOrders[_sellid].tokenToExchange ,SellOrders[_sellid].seller , SellOrders[_sellid].status);
        
        return (SafeMath.sub(buyid_counter,1));


    }

    






    function negotiate(uint256 _sellid , uint256 _price , string calldata _comment ) external returns(uint256) {
        require(msg.sender.balance>=_price,"You do not have the funds to make such an offer");
        CounterOrder memory Order;
        Order.sellOrderID=_sellid;
        Order.buyer=msg.sender;
        Order.price=_price;
        Order.comment=_comment;
        Order.status=CounterOrderstatus.PENDING;

        CounterOrders[negotiate_counter]=Order;
        emit CounterOrderAltered(negotiate_counter,_sellid, _price  , _comment , Order.status );
        negotiate_counter++;
        return (negotiate_counter-1);
    }

    function acceptCounterOrder(uint256 _id) external {
        uint256 sell_id = CounterOrders[_id].sellOrderID;
        require(SellOrders[sell_id].seller==msg.sender,"Only Seller can Accept a Counter Order");
        address buyer=CounterOrders[_id].buyer;
        address seller= SellOrders[sell_id].seller;
  
        CounterOrders[_id].status=CounterOrderstatus.ACCEPTED;
        }

    function buyCounterOrder(uint256 _id) external payable{
        uint256 _sellid = CounterOrders[_id].sellOrderID;
        require(CounterOrders[_id].status==CounterOrderstatus.ACCEPTED,"Counter Order must be accepted");
        
        require(msg.sender==CounterOrders[_id].buyer);
        
        uint256 amount;

        recieveAssets(_sellid);

        SellOrders[_sellid].quantity=SafeMath.sub(SellOrders[_sellid].quantity,1);
        if(SellOrders[_sellid].quantity<=0){
            SellOrders[_sellid].status=Orderstatus.CLOSED;
        }

        
        if(SellOrders[_sellid].paymentOption==PricePaymentOption.TOKEN){
            
            IERC20 tokenAddress=IERC20(SellOrders[_sellid].tokenToExchange);
            amount= CounterOrders[_sellid].price;
            require(tokenAddress.balanceOf(msg.sender)>=amount,"You dont have the funds to buy this token");
            require(tokenAddress.allowance(msg.sender,address(this))>=amount,"Buyer needs to approve required tokens to contract first");
            tokenAddress.transferFrom(msg.sender,SellOrders[_sellid].seller,amount);
            }
        else{
            amount= CounterOrders[_sellid].price;
            require(msg.value>=amount,"You dont have the funds to buy this token");
            SellOrders[_sellid].seller.call{value: msg.value}("");
            }
    

        // SellOrders[sell_id].quantity-=1;
        // if(SellOrders[sell_id].quantity<=0){
        //     SellOrders[sell_id].status=Orderstatus.CLOSED;
        // }

        emit CounterOrderAltered(_id,_sellid, CounterOrders[_sellid].price  , CounterOrders[_id].comment , CounterOrders[_id].status );
        emit SellOrderAltered(_sellid,SellOrders[_sellid].tokenToSell , SellOrders[_sellid].amount ,SellOrders[_sellid].quantity, SellOrders[_sellid].paymentOption, SellOrders[_sellid].price , SellOrders[_sellid].tokenToExchange ,SellOrders[_sellid].seller , SellOrders[_sellid].status);
    }


    function cancelCounterOrder(uint256 _id) external {
        uint256 sell_id = CounterOrders[_id].sellOrderID;
        address buyer=CounterOrders[_id].buyer;
        address seller= SellOrders[sell_id].seller;
        require(msg.sender==seller || msg.sender==buyer,"Only Seller or Owner of the Counter Order can cancel couterOrder");



        if(msg.sender==seller){
            CounterOrders[sell_id].status=CounterOrderstatus.REJECTED;
        }
        else if(msg.sender==buyer){
            CounterOrders[sell_id].status=CounterOrderstatus.CANCELED;
        }

         emit CounterOrderAltered(_id,sell_id, CounterOrders[_id].price  , CounterOrders[_id].comment , CounterOrders[_id].status );
    }

    function increamentQuantity(uint256 sell_id , uint256 quantity) external{
        require(SellOrders[sell_id].seller==msg.sender,"Only Seller of these Orders can deposit Orders");
        SellOrders[sell_id].quantity=SafeMath.add(SellOrders[sell_id].quantity, quantity);
        IERC20 tokenToSell = IERC20(SellOrders[sell_id].tokenToSell);
        uint256 amount=SellOrders[sell_id].amount;
        require(tokenToSell.balanceOf(msg.sender)>=SafeMath.mul(amount,quantity),"Seller must have the funds being put for sale");
        if(SellOrders[sell_id].status==Orderstatus.CLOSED){
            SellOrders[sell_id].status=Orderstatus.FORSALE;
        }


        tokenToSell.transferFrom(msg.sender,address(this),amount*quantity);
        emit SellOrderAltered(sell_id,SellOrders[sell_id].tokenToSell , SellOrders[sell_id].amount,SellOrders[sell_id].quantity, SellOrders[sell_id].paymentOption, SellOrders[sell_id].price , SellOrders[sell_id].tokenToExchange ,SellOrders[sell_id].seller , SellOrders[sell_id].status);

    }

    function decreamentQuantity(uint256 sell_id , uint256 quantity) external{
        require(SellOrders[sell_id].seller==msg.sender,"Only Seller of these Orders can withdraw Orders");
        require(SellOrders[sell_id].quantity>=quantity,"Seller must have enough Orders deposited to withdraw the specific amount");

        IERC20 tokenToSell=IERC20(SellOrders[sell_id].tokenToSell);
        uint256 amount= SellOrders[sell_id].amount;

        tokenToSell.transfer(msg.sender,SafeMath.mul(amount,quantity));
        SellOrders[sell_id].quantity-=quantity;

        if(SellOrders[sell_id].quantity<=0){
            SellOrders[sell_id].status=Orderstatus.CLOSED;
        }
        emit SellOrderAltered(sell_id,SellOrders[sell_id].tokenToSell , SellOrders[sell_id].amount ,SellOrders[sell_id].quantity, SellOrders[sell_id].paymentOption, SellOrders[sell_id].price , SellOrders[sell_id].tokenToExchange ,SellOrders[sell_id].seller , SellOrders[sell_id].status);
    }


    

    


    

}