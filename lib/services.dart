import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;
class StripeResponse{
  final bool success;
  final String mess;
  StripeResponse({this.success, this.mess});
}
class PaymentService {

  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentAPi = '$apiBase/payment_intents';
  static Uri PaymentApiUri=Uri.parse(paymentAPi);
  static String secect =
      'sk_test_51JtmPPFgOhdm0uLBZuhwyanzHa2klXjPy7jTi2ngAWA54BSq1etCm4tQFEbYyOpVkhxK0MgUaOFmurIVeLSpIF6J00eJdpJ4Kp';
  static Map<String, String> header = {
    'Authorization': 'Bearer $secect',
    'Content-type': 'application/x-www-form-urlencoded'
  };
  static init() {
    StripePayment.setOptions(StripeOptions(
      publishableKey:
          "pk_test_51JtmPPFgOhdm0uLBiSoD5HnXRh0TPtSbYPKV14KWHkHV3shjEx5zqVhrGFfZwTViHkhvMg22nrsznl385Iz0RxR4007ptnvkP7",
      androidPayMode: 'test',
      merchantId: 'test',
    ));
  }

  static Future<Map<String, dynamic>> createPaymentIntent(String amount)async {
    try {
      Map<String, dynamic> body = {'amount': "$amount", 'currency': "USD"};
      var response=await http.post(PaymentApiUri,body: body,headers: header);
      return jsonDecode(response.body);
    } catch (err) {
      print("eeeeeeeeeeeeeeeeeeeeeeee $err");
    }
  }

  Future<StripeResponse> createPaymentMEthod({String amount}) async {
    try{
      print("transaction amount ================>");
      var paymentMethod =
      await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      var paymentIntent =await PaymentService.createPaymentIntent(amount);
      var response=await StripePayment.confirmPaymentIntent(PaymentIntent(clientSecret: paymentIntent['client_secret'],paymentMethodId: paymentMethod.id));
      if(response.status=='succeeded'){
        return StripeResponse(mess: "Transaction successful",success: true);
      }else{
        return StripeResponse(mess: "Transaction failed",success: false);
      }
    } on PlatformException catch(error){
      return getPlatf(error);
    }

    catch (er){
      return StripeResponse(mess: "Transaction failed $er",success: false);
    }


  }
static getPlatf(err){
String mess="Something went wrong";
if(err.code=='cancelled'){
  mess="transaction cancelled";
}
return new  StripeResponse(mess: mess,success: false);
}

}
