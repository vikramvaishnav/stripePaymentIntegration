# Flutter Stripe Integration + Firebase

Used Firebase authentication + Firebase firestore + Stripe Payment Gateway

## Things Done ✅
1. User Authentication using Firebase Authentication
2. Connecting User in User collection on Firestore 
3. Create Customer on Strips Server 
4. Updating Firestore Customer with Strips Customer ID (StripId)
5. Adding Card as PaymentMethod to Customer with StripeId on Stripe Server
6. Adding Card in Firestore in a separate collection as card and Store card details
7. Listing All saved cards on App
8. Can Pay Using New card with stripe CardFrom ( Note: not included in this project because first I have saved card) 

[For Payment with newcard function Please Look at this repo](https://github.com/vikramvaishnav/Stripe_Payment_With_NewCard.git)




## Things not able to do it :

1. Not Abel to pay from saved cards

Reason - 

1.1. Tried to use Charge API of Strip's but its deprecated and supported anymore

1.2. Tried Using creating Payment Intent API but getting an error (In method  StripePayment.createPaymentMethod  or at in StripePayment object)

**I also used PostMan to test API but not able to solve the error**

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)