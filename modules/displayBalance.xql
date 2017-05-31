xquery version "3.1";


let $login := xmldb:login("/db", 'admin', '')
let $dateString := request:get-parameter('balanceDate','')

return
    if(fn:matches($dateString,"^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$")) then
    (
    update delete doc("/db/apps/webaccountingxml/templates/balance.html")//p[@class="balanceType"], 
    update delete doc("/db/apps/webaccountingxml/templates/balance.html")//p[@class="totalIncome"],
    update delete doc("/db/apps/webaccountingxml/templates/balance.html")//p[@class="totalExpenses"],
    update delete doc("/db/apps/webaccountingxml/templates/balance.html")//p[@class="totalAmount"],
    update insert <p class="balanceType">Typ bilance: Ke zvolenému datu </p> into doc("/db/apps/webaccountingxml/templates/balance.html")/html/body/div/div,
    update insert <p class="totalIncome">Celkové příjmy:
        { 
            fn:sum(
                    let $closingDateString := doc("/db/apps/webaccountingxml/data/closingdate.xml")/closingdates/closingdate/text()
                    let $closingDate := xs:date($closingDateString)
                    let $balanceDate := xs:date($dateString)
                
                for $payment in doc("/db/apps/webaccountingxml/data/payments.xml")/payments/payment
                where xs:date($payment/date) > $closingDate and xs:date($payment/date) < $balanceDate and $payment/amount/number() > 0
                return xs:integer($payment/amount)
            )
    }</p> into doc("/db/apps/webaccountingxml/templates/balance.html")/html/body/div/div,
    update insert <p class="totalExpenses">Celkové výdaje:
        { 
            fn:sum(
                    let $closingDateString := doc("/db/apps/webaccountingxml/data/closingdate.xml")/closingdates/closingdate/text()
                    let $closingDate := xs:date($closingDateString)
                    let $balanceDate := xs:date($dateString)
                
                for $payment in doc("/db/apps/webaccountingxml/data/payments.xml")/payments/payment
                where xs:date($payment/date) > $closingDate and xs:date($payment/date) < $balanceDate and $payment/amount/number() < 0
                return xs:integer($payment/amount)
            )
    }</p> into doc("/db/apps/webaccountingxml/templates/balance.html")/html/body/div/div,
    update insert <p class="totalAmount">Celková suma:
        { 
            fn:sum(
                    let $closingDateString := doc("/db/apps/webaccountingxml/data/closingdate.xml")/closingdates/closingdate/text()
                    let $closingDate := xs:date($closingDateString)
                    let $balanceDate := xs:date($dateString)
                
                for $payment in doc("/db/apps/webaccountingxml/data/payments.xml")/payments/payment
                where xs:date($payment/date) > $closingDate and xs:date($payment/date) < $balanceDate
                return xs:integer($payment/amount)
            )
    }</p> into doc("/db/apps/webaccountingxml/templates/balance.html")/html/body/div/div,
    response:redirect-to(xs:anyURI("http://localhost:8080/exist/apps/webaccountingxml/templates/balance.html")))
    else
        update insert
            <div class="alert alert-danger">
                <a href="./modules/deleteNotification.xql" class="close">Zrušit</a>
                Neplatné datum - špatně zadaný formát.
            </div> into doc("/db/apps/webaccountingxml/index.html")//div[@class="notification"],
        response:redirect-to(xs:anyURI("http://localhost:8080/exist/apps/webaccountingxml/index.html"))