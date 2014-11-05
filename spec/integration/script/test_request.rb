require 'rest-client'
require 'api_auth'

post_params = {
               "approvalGroup" => "testgroup",
               "cartNumber" => "1357911",
               "category" => "initiation",
               "email" => "raphael.villas@gmail.com",
               "toAddress" => ["communicart.approver1@gmail.com", "communicart.approver2@gmail.com"],
               "fromAddress" => "raphael.villas@gsa.gov",
               "cartItems[]" => [{
                 "vendor" => "DOCUMENT IMAGING DIMENSIONS, INC.",
                 "description" => "ROUND RING VIEW BINDER WITH INTERIOR POC",
                 "url" => "/advantage/catalog/product_detail.do?&oid=704213980&baseOid=&bpaNumber=GS-02F-XA002",
                 "notes" => "",
                 "qty" => "24",
                 "details" => "Direct Delivery 3-4 days delivered ARO",
                 "socio" => [],
                 "partNumber" => "7510-01-519-4381",
                 "price" => "$2.46",
                 "features" => ["sale"]
               }]
              }

headers = {
  'Content-MD5' => "",
  'Content-Type' => "text/plain",
  'Date' => "Mon, 23 Jan 1984 03:29:56 GMT"
}

url = 'http://localhost:3000/send_cart'
request = RestClient::Request.new(:url => url,
        :headers => headers,
        :method => :post)

signed_request = ApiAuth.sign!(request, '1a2b3c4d5e', 'hjtgRmVLKJnw5Res/qnkTTnA6uM9GyJGlRzVakBHqXd2fT4F2Tcq1IZM5XfCCoK4vKaFUQIaDwZJSFKkf1Ad4A==')

RestClient.post url, post_params, signed_request.headers

