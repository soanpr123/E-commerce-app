import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/model/cartmodel.dart';

import 'package:e_commerce/provider/product_provider.dart';
import 'package:e_commerce/screens/homepage.dart';
import 'package:e_commerce/services.dart';
import 'package:e_commerce/widgets/checkout_singleproduct.dart';
import 'package:e_commerce/widgets/mybutton.dart';
import 'package:e_commerce/widgets/notification_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class CheckOut extends StatefulWidget {
  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  TextStyle myStyle = TextStyle(
    fontSize: 18,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProductProvider productProvider;
  PaymentMethod paymentMethod;
  Widget _buildBottomSingleDetail({String startName, String endName}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          startName,
          style: myStyle,
        ),
        Text(
          endName,
          style: myStyle,
        ),
      ],
    );
  }

  User user;
  double total;
  List<CartModel> myList;
  Future<bool> PayWithCard({int amount}) async {
    var response = await PaymentService()
        .createPaymentMEthod(amount: amount.toString());
    print("/////===> ${response.mess}");
    if(response.success==true){
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(response.mess),
        duration: Duration(seconds: response.success == true ? 3 : 5),
      ));
      return true;
    }else{
      return false;
    }

  }

  Widget _buildButton() {
    return Column(
        children: productProvider.userModelList.map((e) {
      return Container(
        height: 50,
        child: MyButton(
          name: "Thanh toán",
          onPressed: () async {
            double amountcell= total *1000;
            int intergerTotal=(amountcell/10).ceil();
            PayWithCard(amount: intergerTotal).then((value) {

              if(value==true){
                if (productProvider.getCheckOutModelList.isNotEmpty) {
                  FirebaseFirestore.instance.collection("Order").add({
                    "Product": productProvider.getCheckOutModelList
                        .map((c) => {
                      "ProductName": c.name,
                      "ProductPrice": c.price,
                      "ProductQuetity": c.quentity,
                      "ProductImage": c.image,
                      "Product Color": c.color,
                      "Product Size": c.size,
                    })
                        .toList(),
                    "TotalPrice": total.toStringAsFixed(2),
                    "UserName": e.userName,
                    "UserEmail": e.userEmail,
                    "UserNumber": e.userPhoneNumber,
                    "UserAddress": e.userAddress,
                    "UserId": user.uid,
                  });
                  setState(() {
                    myList.clear();
                  });

                  productProvider.addNotification("Notification");
                } else {
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text("No Item Yet"),
                    ),
                  );
                }
              }else{
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text("Transaction failded"),
                  duration: Duration(seconds: 5),
                ));
              }
            });
            // print(paymentMethod.id);

          },
        ),
      );
    }).toList());
  }

  @override
  void initState() {
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    myList = productProvider.checkOutModelList;
    PaymentService.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = FirebaseAuth.instance.currentUser;
    double subTotal = 0;
    double discount = 3;
    double discountRupees;
    double shipping = 60;

    productProvider = Provider.of<ProductProvider>(context);
    productProvider.getCheckOutModelList.forEach((element) {
      subTotal += element.price * element.quentity;
    });

    discountRupees = discount / 100 * subTotal;
    total = subTotal + shipping - discountRupees;
    if (productProvider.checkOutModelList.isEmpty) {
      total = 0.0;
      discount = 0.0;
      shipping = 0.0;
    }

    return WillPopScope(
      onWillPop: () async {
        return Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => HomePage(),
          ),
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Giỏ hàng", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => HomePage(),
                ),
              );
            },
          ),
          actions: <Widget>[
            NotificationButton(),
          ],
        ),
        bottomNavigationBar: Container(
          height: 70,
          width: 100,
          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.only(bottom: 15),
          child: _buildButton(),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: ListView.builder(
                    itemCount: myList.length,
                    itemBuilder: (ctx, myIndex) {
                      return CheckOutSingleProduct(
                        index: myIndex,
                        color: myList[myIndex].color,
                        size: myList[myIndex].size,
                        image: myList[myIndex].image,
                        name: myList[myIndex].name,
                        price: myList[myIndex].price,
                        quentity: myList[myIndex].quentity,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _buildBottomSingleDetail(
                        startName: "Tổng sản phẩm",
                        endName: "\$ ${subTotal.toStringAsFixed(2)}",
                      ),
                      _buildBottomSingleDetail(
                        startName: "Giảm giá",
                        endName: "${discount.toStringAsFixed(2)}%",
                      ),
                      _buildBottomSingleDetail(
                        startName: "Phí vận chuyển",
                        endName: "\$ ${shipping.toStringAsFixed(2)}",
                      ),
                      _buildBottomSingleDetail(
                        startName: "Tổng thanh toán",
                        endName: "\$ ${total.toStringAsFixed(2)}",
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
