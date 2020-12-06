import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart' as stripkar;
import 'package:mastering_payments/services/cards.dart';
import 'package:mastering_payments/services/user.dart';
import 'package:mastering_payments/provider/user_provider.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeServices {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeServices.apiBase}/payment_intents';

  static const PUBLISHABLE_KEY =
      "pk_test_51HuzGEELsLSfcXBkZzSJLqyBPCMWtxqb9MFgAayLTOvDweihjZEYSXndRm6EY5rU3HtckouhI7EW3z7LkBsVjQw000VZqLhgh3";
  static const SECRET_KEY =
      "sk_test_51HuzGEELsLSfcXBkw1d7XKchJMTdsNZlWh6jeD7ANBRYo6Oq5OH3aVTr1FUap0Qq9mY332P8K8Ako3ObOtFR65NG00VLqcUjEm";
  static const PAYMENT_METHOD_URL = "https://api.stripe.com/v1/payment_methods";
  static const CUSTOMERS_URL = "https://api.stripe.com/v1/customers";
  static const CHARGE_URL = "https://api.stripe.com/v1/charges";

  static Map<String, String> headers = {
    'Authorization': "Bearer  $SECRET_KEY",
    "Content-Type": "application/x-www-form-urlencoded"
  };

  StripeServices() {
    //
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(message: message, success: false);
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(StripeServices.paymentApiUrl,
          body: body, headers: StripeServices.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charing user: ${err.toString()}');
    }
    return null;
  }

  Future<void> getData() async {
    stripkar.StripeOptions(
        publishableKey: StripeServices.PUBLISHABLE_KEY,
        merchantId: "Test",
        androidPayMode: 'test');
  }

  Future<StripeTransactionResponse> payViaExistingCard(
      {String amount, String currency, stripkar.CreditCard currentCard}) async {
    try {
      // if (stripkar.StripePayment == null) print("Null aahe re baba");
      // var paymentMethod = await stripkar.StripePayment.createPaymentMethod(
      //     stripkar.PaymentMethodRequest(card: currentCard));

      var paymentIntent =
          await StripeServices.createPaymentIntent(amount, currency);
      var response = await stripkar.StripePayment.confirmPaymentIntent(
          stripkar.PaymentIntent(
        clientSecret: paymentIntent['client_secret'],
        paymentMethodId: "pm_1HvNuiELsLSfcXBkYFD6cZsU",
      ));
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful', success: true);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed}', success: false);
      }
    } on PlatformException catch (err) {
      return StripeServices.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  Future<String> createStripeCustomer({String email, String userId}) async {
    Map<String, String> body = {
      'email': email,
    };

    String stripeId = await http
        .post(CUSTOMERS_URL, body: body, headers: headers)
        .then((response) {
      String stripeId = jsonDecode(response.body)["id"];
      print("The stripe id is: $stripeId");
      UserService userService = UserService();
      userService.updateDetails({"id": userId, "stripeId": stripeId});
      return stripeId;
    }).catchError((err) {
      print("==== THERE WAS AN ERROR ====: ${err.toString()}");
      return null;
    });

    return stripeId;
  }

  Future<void> addCard(
      {int cardNumber,
      int month,
      int year,
      int cvc,
      String stripeId,
      String userId}) async {
    Map body = {
      "type": "card",
      "card[number]": cardNumber,
      "card[exp_month]": month,
      "card[exp_year]": year,
      "card[cvc]": cvc
    };
    Dio()
        .post(PAYMENT_METHOD_URL,
            data: body,
            options: Options(
                contentType: Headers.formUrlEncodedContentType,
                headers: headers))
        .then((response) {
      String paymentMethod = response.data["id"];

      print("=== The payment mathod id id ===: $paymentMethod");
      http
          .post(
              "https://api.stripe.com/v1/payment_methods/$paymentMethod/attach",
              body: {"customer": stripeId},
              headers: headers)
          .catchError((err) {
        print("ERROR ATTACHING CARD TO CUSTOMER");
        print("ERROR: ${err.toString()}");
      });

      CardServices cardServices = CardServices();
      cardServices.createCard(
          id: paymentMethod,
          last4: int.parse(cardNumber.toString().substring(12)),
          exp_month: month,
          exp_year: year,
          userId: userId);
      UserService userService = UserService();
      userService.updateDetails({"id": userId, "activeCard": paymentMethod});
    });
  }

  Future<bool> charge({
    String customer,
    int amount,
    String cardId,
  }) async {
    Map<String, dynamic> data = {
      "amount": amount,
      "currency": "inr",
      "source": cardId,
      "customer": customer
    };
    try {
      Dio()
          .post(CHARGE_URL,
              data: data,
              options: Options(
                  contentType: Headers.formUrlEncodedContentType,
                  headers: headers))
          .then((response) {
        print(response.toString());
      });
      // PurchaseServices purchaseServices = PurchaseServices();
      // var uuid = Uuid();
      // var purchaseId = uuid.v1();
      // purchaseServices.createPurchase(id: purchaseId, amount: amount, cardId: cardId, userId: userId, productName: productName);
      return true;
    } catch (e) {
      print("there was an error charging the customer: ${e.toString()}");
      return false;
    }
  }
}
