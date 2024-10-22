codeunit 50766 "Emkan Integration"
{
    TableNo = 99008906;
    SingleInstance = true;
    trigger OnRun()
    begin
        GlobalRec := Rec;
        IF PosTr.GET(GlobalRec."Current-RECEIPT") THEN;
        POSTransCode := GlobalRec."Current-RECEIPT";
        CASE GlobalRec.Command OF
            'EMKAN_REDEEM':
                EmkanPayment();
        END
    end;

    var
        GlobalRec: Record "LSC POS Menu Line";
        PosTr: Record "LSC POS Transaction";
        EposCtrl: Codeunit "LSC POS Control Interface";
        EmkanEntryTable: Record "Emkan Integration - EDM";
        LastEmkanEntry: Record "Emkan Integration - EDM";
        Phn: Text;
        InputOk: Boolean;
        POSTransCode: Code[20];
        POSTrans: Codeunit "LSC POS Transaction";
        POSGUI: Codeunit "LSC POS GUI";
        TransAmt: Decimal;
        AmtTxt: text;
        POSTransLine: Record "LSC POS Trans. Line";

    procedure EmkanPayment()
    var
        Customer: Record Customer;
        lRetailSetup: Record "LSC Retail Setup";
    begin
        lRetailSetup.Get();
        POSTransLine.SetRange("Store No.", EmkanEntryTable."Store No.");
        POSTransLine.SetRange("Receipt No.", EmkanEntryTable."Receipt No.");
        POSTransLine.SetFilter(Number, lRetailSetup."Emkan Tender Type");
        if POSTransLine.FindFirst() then begin
            if not Confirm('لديك بالفعل عملية دفع إمكان بقيمة 1% , هل تريد تنفيذ عملية أخرى؟', False, POSTransLine.Amount) then
                exit;
        end;

        if PosTr."Sale Is Return Sale" then begin
            EmkanEntryTable.LockTable();
            EmkanEntryTable.Init();
            EmkanEntryTable.SetRange("Store No.", PosTr."Retrieved from Store No.");
            EmkanEntryTable.SetRange("Receipt No.", PosTr."Retrieved from Receipt No.");
            if EmkanEntryTable.FindLast() then begin
                EmkanEntryTable."Refund Receipt No." := PosTr."Receipt No.";
                EmkanEntryTable.Modify();
                RefundProcess(EmkanEntryTable);
            end;
        end else begin
            EmkanEntryTable.LockTable();
            EmkanEntryTable.Init();
            EmkanEntryTable.SetRange("Receipt No.", PosTr."Receipt No.");
            EmkanEntryTable.SetRange("Store No.", PosTr."Store No.");
            if not EmkanEntryTable.FindFirst() then begin
                LastEmkanEntry.Reset();
                LastEmkanEntry.SetRange("POS Terminal No.", PosTr."POS Terminal No.");
                LastEmkanEntry.SetRange("Store No.", PosTr."Store No.");
                if LastEmkanEntry.FindLast() then
                    EmkanEntryTable."Entry No." := LastEmkanEntry."Entry No." + 1
                else
                    EmkanEntryTable."Entry No." := 1;
                EmkanEntryTable."Receipt No." := PosTr."Receipt No.";
                EmkanEntryTable."Store No." := PosTr."Store No.";
                EmkanEntryTable."POS Terminal No." := PosTr."POS Terminal No.";
                EmkanEntryTable."Trans. Date" := PosTr."Trans. Date";
                EmkanEntryTable.Insert();
                EPosCtrl.OpenNumericKeyboard('باركود القسيمة' + '/' + 'Scan Voucher Barcode', '', '#Scan_Barcode');
            end else begin
                EPosCtrl.OpenNumericKeyboard('باركود القسيمة' + '/' + 'Scan Voucher Barcode', EmkanEntryTable."Voucher No.", '#Scan_Barcode');
            end;
        end;
        //EPosCtrl.OpenNumericKeyboard('باركود القسيمة' + '/' + 'Scan Voucher Barcode', '', '#Scan_Barcode');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeInsertPaymentEntryV2', '', false, false)]
    local procedure OnBeforeInsertPaymentEntry(VAR POSTransaction: Record "LSC POS Transaction"; VAR TransPaymentEntry: Record "LSC Trans. Payment Entry")
    var
        POSTransactionLine: Record "LSC POS Trans. Line";
        lEmkanEntryTable: Record "Emkan Integration - EDM";
        lRetailSetup: Record "LSC Retail Setup";
    begin
        lEmkanEntryTable.Reset();
        lEmkanEntryTable.SetRange("Receipt No.", POSTransaction."Receipt No.");
        if lEmkanEntryTable.FindFirst() then begin
            lRetailSetup.get();
            // POSTransactionLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
            // POSTransactionLine.SetRange("POS Terminal No.", POSTransaction."POS Terminal No.");
            POSTransactionLine.SetRange("Entry Type", POSTransactionLine."Entry Type"::Payment);
            POSTransactionLine.SetRange("Receipt No.", lEmkanEntryTable."Receipt No.");
            POSTransactionLine.SetRange("POS Terminal No.", lEmkanEntryTable."POS Terminal No.");
            POSTransactionLine.SetRange(Number, lRetailSetup."Emkan Tender Type");
            POSTransactionLine.SetFilter(Amount, '<>%1', 0);
            if POSTransactionLine.FindFirst() then begin
                TransPaymentEntry."Emkan Voucher no." := lEmkanEntryTable."Voucher No.";
                TransPaymentEntry."Emkan Voucher Id" := lEmkanEntryTable."Voucher Id";
                //TransPaymentEntry.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterVoidLine', '', false, false)]
    local procedure OnAfterVoidLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line")
    var
        TransID: integer;
        TransPaymentEntry: Record "LSC Trans. Payment Entry";
    begin
        //if not POSTransaction."Sale Is Return Sale" then
        //if (POSTransaction."Is  Payment" = true) then begin
        //if (POSTransLine.Number = '13') and (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Payment) then begin
        // EmkanEntryTable.SetRange("Receipt No.", POSTransaction."Receipt No.");
        // EmkanEntryTable.SetRange("Store No.", POSTransaction."Store No.");
        //if EmkanEntryTable.FindLast() then begin
        //Evaluate(TransID, EmkanEntryTable." Transaction No.");
        //AlIntegration.ReverseRedeemBLUCustomer(TransID);
        //end;
        //end;
        /* if POSTransaction."Sale Is Return Sale" then begin
             TransPaymentEntry.SetRange("Is  Payment", true);
             TransPaymentEntry.SetRange("Transaction No.", POSTransaction."Retrieved from Trans. No.");
             TransPaymentEntry.SetRange("Store No.", POSTransaction."Retrieved from Store No.");
             TransPaymentEntry.SetRange("POS Terminal No.", POSTransaction."Retrieved from POS Term. No.");
             if TransPaymentEntry.FindFirst() then begin
                 Message(TransPaymentEntry." Trans. No");
                 Evaluate(TransID, TransPaymentEntry." Trans. No");
                 AlIntegration.ReverseRedeemBLUCustomer(TransID);
             end;
         end;*/

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterVoidTransaction', '', false, false)]
    local procedure OnAfterVoidTransaction(var POSTransaction: Record "LSC POS Transaction")
    var
        TransID: integer;
        TransPaymentEntry: Record "LSC Trans. Payment Entry";
    begin
        /*if not POSTransaction."Sale Is Return Sale" then begin
            EmkanEntryTable.SetRange("Receipt No.", POSTransaction."Receipt No.");
            if EmkanEntryTable.FindFirst() then begin
                //Message(EmkanEntryTable."Transaction No.");
                //Evaluate(TransID, EmkanEntryTable."Transaction No.");
                //AlIntegration.ReverseRedeemBLUCustomer(TransID);
            end;
        end;*/
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnAfterInsertPaymentLine', '', false, false)]
    local procedure OnAfterInsertPaymentLine(var POSTransaction: Record "LSC POS Transaction"; var POSTransLine: Record "LSC POS Trans. Line"; var CurrInput: Text; var TenderTypeCode: Code[10])
    var
    begin
        /*if (POSTransLine.Number = '13') and (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Payment) and (POSTransLine.Amount <> 0) then begin
            POSTransaction."Is  Payment" := true;
            POSTransaction." Trans. No" := EmkanEntryTable."Transaction No.";
            POSTransaction.Modify(false);
            EmkanEntryTable.DeleteAll();
        end;*/
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"LSC POS Controller", 'OnNumpadResult', '', false, false)]
    local procedure OnNumpadResult(payload: Text; inputValue: Text; resultOK: Boolean; VAR processed: Boolean)
    var
        BLUCustMobResponse: HttpResponseMessage;
        lHttpResponce: HttpResponseMessage;
        MobBLUResponseText: text;
        lResponseText: text;
        Jsonbody: JsonObject;
        JsonToken: JsonToken;
        POSTransCU: Codeunit "LSC POS Transaction";
        lRetailSetup: Record "LSC Retail Setup";
        ErrorMsgToken: JsonToken;
        VoucherAmount: Decimal;
    begin
        case payload of
            '#Scan_Barcode':
                begin
                    clear(Phn);
                    processed := true;
                    IF inputValue <> '' THEN begin
                        EmkanEntryTable.LockTable();
                        EmkanEntryTable.SetRange("Receipt No.", POSTransCU.GetReceiptNo());
                        EmkanEntryTable.SetRange("Store No.", POSTransCU.GetStoreNo());
                        if EmkanEntryTable.FindLast() then begin
                            EmkanEntryTable."Voucher No." := inputValue;
                            EmkanEntryTable.Modify();
                            EPosCtrl.OpenNumericKeyboard('رمز التطبيق' + '/' + 'ApplicationId', EmkanEntryTable."Application Id", '#Ins_AppId');
                        end;
                    end else begin
                        Message('Insert Mobile No.');
                        exit;
                    end;
                end;
            '#Ins_AppId':
                begin
                    processed := True;
                    IF inputValue <> '' THEN
                        resultOK := true;
                    If resultOK THEN begin
                        //OTPValue := inputValue;
                        InputOk := True;
                        //Message(OTPValue);
                        EmkanEntryTable.LockTable();
                        EmkanEntryTable.SetRange("Receipt No.", POSTransCU.GetReceiptNo());
                        EmkanEntryTable.SetRange("Store No.", POSTransCU.GetStoreNo());
                        if EmkanEntryTable.FindLast() then begin
                            EmkanEntryTable."Application Id" := inputValue;
                            EmkanEntryTable.Modify();
                            EPosCtrl.OpenNumericKeyboard('رمز العميل' + '/' + 'CustomerId', EmkanEntryTable."Customer Id", '#Ins_CustId');
                        end;
                    END
                    else
                        Message('Insert OTP');

                end;

            '#Ins_CustId':
                begin

                    processed := true;
                    if not resultOK then
                        exit;

                    // OTPValue := inputValue;
                    // InputOk := True;
                    //Message(OTPValue);
                    //EmkanEntryTable.LockTable();
                    EmkanEntryTable.SetRange("Receipt No.", POSTransCU.GetReceiptNo());
                    EmkanEntryTable.SetRange("Store No.", POSTransCU.GetStoreNo());
                    if EmkanEntryTable.FindLast() then begin
                        EmkanEntryTable."Customer Id" := inputValue;
                        EmkanEntryTable.Modify();
                        Commit();

                        lHttpResponce := GetVoucherDetails(EmkanEntryTable);
                        lHttpResponce.Content.ReadAs(lResponseText);
                        if lHttpResponce.IsSuccessStatusCode then begin
                            if ParseJsonText('status', lResponseText) = 'EXPIRED' then begin
                                Message('Current Voucher expired!');
                                exit;
                            end;
                            Message(lResponseText);
                            VoucherAmount := ParseJsonDecimal('amount', lResponseText);
                            // EmkanEntryTable."Voucher Amount" := ParseJsonDecimal('Amount', lResponseText);
                            // EmkanEntryTable.Modify();
                            if POSTransCU.GetAmount() < VoucherAmount then begin
                                if not Confirm('قيمة الفاتورة أقل من القسيمة %1 هل تريد استخدام قسيمة أخرى', False, VoucherAmount) then begin
                                    EmkanEntryTable.Delete();
                                    exit;
                                end else begin
                                    EPosCtrl.OpenNumericKeyboard('باركود القسيمة' + '/' + 'Scan Voucher Barcode', '', '#Scan_Barcode');
                                end;

                            end else begin
                                if not Confirm('إستمر بالدفع عن طريق قسيمة إمكان بقيمة %1', False, VoucherAmount) then begin
                                    EmkanEntryTable.Delete();
                                    exit;
                                end else begin
                                    Clear(lHttpResponce);
                                    Clear(lResponseText);
                                    lHttpResponce := PreRedeem(EmkanEntryTable."Customer Id");
                                    lHttpResponce.Content.ReadAs(lResponseText);
                                    if lHttpResponce.IsSuccessStatusCode then begin
                                        //EmkanEntryTable.LockTable();
                                        // EmkanEntryTable.SetRange("Receipt No.", POSTransCU.GetReceiptNo());
                                        // EmkanEntryTable.SetRange("Store No.", POSTransCU.GetStoreNo());
                                        // if EmkanEntryTable.FindLast() then begin
                                        EmkanEntryTable."OTP Id" := ParseJsonText('otpID', lResponseText);
                                        EmkanEntryTable."Voucher Amount" := VoucherAmount;
                                        EmkanEntryTable.Modify();
                                        //end;
                                        EPosCtrl.OpenNumericKeyboard('الرقم السري' + '/' + 'OTP Value', '', '#Ins_OTP');
                                    end else
                                        Message(ParseJsonText('message', lResponseText));
                                end;

                            end;
                        end else
                            Message(ParseJsonText('message', lResponseText));
                    end;

                end;
            '#Ins_OTP':
                begin
                    processed := true;
                    if not resultOK then
                        exit;

                    EmkanEntryTable.LockTable();
                    EmkanEntryTable.SetRange("Receipt No.", POSTransCU.GetReceiptNo());
                    EmkanEntryTable.SetRange("Store No.", POSTransCU.GetStoreNo());
                    if EmkanEntryTable.FindLast() then begin
                        EmkanEntryTable."OTP Value" := inputValue;
                        EmkanEntryTable.Modify();
                        Commit();
                        Clear(lHttpResponce);
                        Clear(lResponseText);
                        lHttpResponce := Redeem(EmkanEntryTable, POSTransCU.GetReceiptNo());
                        lHttpResponce.Content.ReadAs(lResponseText);
                        if lHttpResponce.IsSuccessStatusCode then begin
                            //EmkanEntryTable.LockTable();
                            // EmkanEntryTable.SetRange("Receipt No.", POSTransCU.GetReceiptNo());
                            // EmkanEntryTable.SetRange("Store No.", POSTransCU.GetStoreNo());
                            // if EmkanEntryTable.FindLast() then begin
                            EmkanEntryTable."Voucher Id" := ParseJsonObject('voucher', lResponseText, 'id');
                            EmkanEntryTable.Modify();
                            //end;
                            lRetailSetup.Get();
                            POSTransCU.TenderKeyPressedEx(lRetailSetup."Emkan Tender Type", format(EmkanEntryTable."Voucher Amount"));
                        end else begin
                            if ParseJsonText('code', lResponseText) = '4013' then begin
                                Message(ParseJsonText('message', lResponseText) + ',أدخل الرمز مرة أخرى');
                                EPosCtrl.OpenNumericKeyboard('الرقم السري' + '/' + 'OTP Value', '', '#Ins_OTP');
                            end else
                                Message(ParseJsonText('message', lResponseText));
                        end;
                    end;
                end;
            '#Ins_RefOTP':
                begin
                    processed := true;
                    if not resultOK then
                        exit;
                    // processed := True;
                    // IF inputValue <> '' THEN
                    //     resultOK := true;
                    // If resultOK THEN begin
                    //     OTPValue := inputValue;
                    //     InputOk := True;
                    //Message(OTPValue);
                    EmkanEntryTable.LockTable();
                    EmkanEntryTable.SetRange("Refund Receipt No.", POSTransCU.GetReceiptNo());
                    EmkanEntryTable.SetRange("Store No.", POSTransCU.GetStoreNo());
                    if EmkanEntryTable.FindLast() then begin
                        EmkanEntryTable."OTP Value" := inputValue;
                        EmkanEntryTable.Modify();
                        Commit();
                        Clear(lHttpResponce);
                        Clear(lResponseText);
                        lHttpResponce := Refund(EmkanEntryTable);
                        lHttpResponce.Content.ReadAs(lResponseText);
                        if lHttpResponce.IsSuccessStatusCode then begin
                            lRetailSetup.Get();
                            POSTransCU.TenderKeyPressedEx(lRetailSetup."Emkan Tender Type", format(EmkanEntryTable."Voucher Amount"));
                        end else begin
                            if ParseJsonText('code', lResponseText) = '4013' then begin
                                Message(ParseJsonText('message', lResponseText) + ',أدخل الرمز مرة أخرى');
                                EPosCtrl.OpenNumericKeyboard('الرقم السري' + '/' + 'OTP Value', '', '#Ins_RefOTP');
                            end else
                                Message(ParseJsonText('message', lResponseText));
                        end;
                    end else
                        Error('Receipt Not Found!');
                end;
        end;
    end;





    procedure PreRedeem(CustomerId: text) HttpRespone: HttpResponseMessage
    Var
        client: HttpClient;
        cont: HttpContent;
        header: HttpHeaders;
        header2: HttpHeaders;
        response: HttpResponseMessage;
        ReqHeader: HttpRequestMessage;
        tmpString: Text;
        ResponseText: text;
        Jsonbody: JsonObject;
        lRetailSetup: Record "LSC Retail Setup";
    Begin
        lRetailSetup.get();
        clear(ResponseText);

        Jsonbody.Add('customerId', CustomerId);
        // Jsonbody.Add('currency', 'SAR');
        // Jsonbody.ADD('lang', 'ar');
        Jsonbody.WriteTo(tmpString);

        cont.WriteFrom(tmpString);
        cont.ReadAs(tmpString);
        cont.GetHeaders(header);
        header.Remove('Content-Type');
        header.Add('Content-Type', 'application/json');
        ReqHeader.Content(cont);

        header2.Clear();
        ReqHeader.GetHeaders(header2);
        header2.Add('LNG', 'AR');
        header2.Add('CHN', 'ECOMMERCE');
        header2.Add('MERCHANT_CODE', 'AlsaifGallery');
        // header2.Add('Authorization', 'Basic aHBYdXNwUVVqeTBWdDJ1ZnNVR1lZZjF2bGJJYTpwMUpIM05NWWZ0cG1jNEtiZGQ4eG56cWhuamNh');
        // ReqHeader.SetRequestUri('https://sit-b2b.emkanfinance.com.sa/merchant/v1/vouchers/preRedeem');//Test API
        if lRetailSetup."Apply Emkan SIT" then begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan SIT Username", lRetailSetup."Emkan SIT Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Pre-Redeem SIT API");
        end else begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan Username", lRetailSetup."Emkan Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Pre-Redeem API");
        end;
        ReqHeader.Method('POST');
        client.Send(ReqHeader, response);
        exit(response);

    end;

    procedure Redeem(pEmkanRec: Record "Emkan Integration - EDM"; ReceiptNo: code[20]) HttpRespone: HttpResponseMessage
    Var
        client: HttpClient;
        cont: HttpContent;
        header: HttpHeaders;
        header2: HttpHeaders;
        response: HttpResponseMessage;
        ReqHeader: HttpRequestMessage;
        tmpString: Text;
        ResponseText: text;
        Jsonbody: JsonObject;
        lRetailSetup: Record "LSC Retail Setup";
    Begin
        lRetailSetup.get();
        clear(ResponseText);

        Jsonbody.Add('customerId', pEmkanRec."Customer Id");
        Jsonbody.Add('voucherCode', pEmkanRec."Voucher No.");
        Jsonbody.ADD('transactionId', ReceiptNo);
        Jsonbody.ADD('otp', pEmkanRec."OTP Value");
        Jsonbody.ADD('otpID', pEmkanRec."OTP Id");
        Jsonbody.WriteTo(tmpString);

        cont.WriteFrom(tmpString);
        cont.ReadAs(tmpString);
        cont.GetHeaders(header);
        header.Remove('Content-Type');
        header.Add('Content-Type', 'application/json');
        ReqHeader.Content(cont);

        header2.Clear();
        ReqHeader.GetHeaders(header2);
        header2.Add('LNG', 'AR');
        header2.Add('CHN', 'ECOMMERCE');
        header2.Add('MERCHANT_CODE', 'AlsaifGallery');
        // header2.Add('Authorization', 'Basic aHBYdXNwUVVqeTBWdDJ1ZnNVR1lZZjF2bGJJYTpwMUpIM05NWWZ0cG1jNEtiZGQ4eG56cWhuamNh');

        // ReqHeader.SetRequestUri('https://sit-b2b.emkanfinance.com.sa/merchant/v1/vouchers/Redeem');//Test API
        if lRetailSetup."Apply Emkan SIT" then begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan SIT Username", lRetailSetup."Emkan SIT Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Redeem SIT API");
        end else begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan Username", lRetailSetup."Emkan Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Redeem API");
        end;
        //ReqHeader.SetRequestUri('');//Production API
        ReqHeader.Method('POST');
        client.Send(ReqHeader, response);
        //Response.Content.ReadAs(ResponseText);
        exit(response);

    end;

    procedure PreRefund(CustomerId: Text) HttpRespone: HttpResponseMessage
    Var
        client: HttpClient;
        cont: HttpContent;
        header: HttpHeaders;
        header2: HttpHeaders;
        response: HttpResponseMessage;
        ReqHeader: HttpRequestMessage;
        tmpString: Text;
        ResponseText: text;
        Jsonbody: JsonObject;
        lRetailSetup: Record "LSC Retail Setup";
    Begin
        lRetailSetup.get();
        clear(ResponseText);

        Jsonbody.Add('customerId', CustomerId);
        // Jsonbody.Add('currency', 'SAR');
        // Jsonbody.ADD('lang', 'ar');
        Jsonbody.WriteTo(tmpString);

        cont.WriteFrom(tmpString);
        cont.ReadAs(tmpString);
        cont.GetHeaders(header);
        header.Remove('Content-Type');
        header.Add('Content-Type', 'application/json');
        ReqHeader.Content(cont);

        header2.Clear();
        ReqHeader.GetHeaders(header2);
        header2.Add('LNG', 'AR');
        header2.Add('CHN', 'ECOMMERCE');
        header2.Add('MERCHANT_CODE', 'AlsaifGallery');
        // header2.Add('Authorization', 'Basic aHBYdXNwUVVqeTBWdDJ1ZnNVR1lZZjF2bGJJYTpwMUpIM05NWWZ0cG1jNEtiZGQ4eG56cWhuamNh');
        // ReqHeader.SetRequestUri('https://sit-b2b.emkanfinance.com.sa/merchant/v1/vouchers/preRedeem');//Test API
        if lRetailSetup."Apply Emkan SIT" then begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan SIT Username", lRetailSetup."Emkan SIT Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Pre-Refund SIT API");
        end else begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan Username", lRetailSetup."Emkan Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Pre-Refund API");
        end;
        ReqHeader.Method('POST');
        client.Send(ReqHeader, response);
        exit(response);

    end;

    procedure Refund(pEmkanRec: Record "Emkan Integration - EDM") HttpRespone: HttpResponseMessage
    Var
        client: HttpClient;
        cont: HttpContent;
        header: HttpHeaders;
        header2: HttpHeaders;
        response: HttpResponseMessage;
        ReqHeader: HttpRequestMessage;
        tmpString: Text;
        ResponseText: text;
        Jsonbody: JsonObject;
        lRetailSetup: Record "LSC Retail Setup";
    Begin
        lRetailSetup.get();
        clear(ResponseText);

        Jsonbody.Add('customerId', pEmkanRec."Customer Id");
        Jsonbody.Add('voucherId', pEmkanRec."Voucher Id");
        Jsonbody.ADD('otp', pEmkanRec."OTP Value");
        Jsonbody.ADD('otpID', pEmkanRec."OTP Id");
        Jsonbody.WriteTo(tmpString);

        cont.WriteFrom(tmpString);
        cont.ReadAs(tmpString);
        cont.GetHeaders(header);
        header.Remove('Content-Type');
        header.Add('Content-Type', 'application/json');
        ReqHeader.Content(cont);

        header2.Clear();
        ReqHeader.GetHeaders(header2);
        header2.Add('LNG', 'AR');
        header2.Add('CHN', 'ECOMMERCE');
        header2.Add('MERCHANT_CODE', 'AlsaifGallery');
        // header2.Add('Authorization', 'Basic aHBYdXNwUVVqeTBWdDJ1ZnNVR1lZZjF2bGJJYTpwMUpIM05NWWZ0cG1jNEtiZGQ4eG56cWhuamNh');

        // ReqHeader.SetRequestUri('https://sit-b2b.emkanfinance.com.sa/merchant/v1/vouchers/Redeem');//Test API
        if lRetailSetup."Apply Emkan SIT" then begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan SIT Username", lRetailSetup."Emkan SIT Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Refund SIT API");
        end else begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan Username", lRetailSetup."Emkan Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Refund API");
        end;
        //ReqHeader.SetRequestUri('');//Production API
        ReqHeader.Method('POST');
        client.Send(ReqHeader, response);
        //Response.Content.ReadAs(ResponseText);
        exit(response);

    end;

    procedure GetVoucherDetails(VoucherRec: Record "Emkan Integration - EDM") HttpRespone: HttpResponseMessage
    Var
        client: HttpClient;
        cont: HttpContent;
        header: HttpHeaders;
        header2: HttpHeaders;
        response: HttpResponseMessage;
        ReqHeader: HttpRequestMessage;
        tmpString: Text;
        ResponseText: text;
        Jsonbody: JsonObject;
        lRetailSetup: Record "LSC Retail Setup";
    Begin
        lRetailSetup.Get();
        clear(ResponseText);
        Jsonbody.Add('voucherCode', VoucherRec."Voucher No.");
        Jsonbody.Add('customerId', VoucherRec."Customer Id");
        Jsonbody.Add('applicationId', VoucherRec."Application Id");

        Jsonbody.WriteTo(tmpString);

        cont.WriteFrom(tmpString);
        cont.ReadAs(tmpString);
        cont.GetHeaders(header);
        header.Remove('Content-Type');
        header.Add('Content-Type', 'application/json');
        ReqHeader.Content(cont);

        header2.Clear();
        ReqHeader.GetHeaders(header2);
        header2.Add('LNG', 'AR');
        header2.Add('CHN', 'ECOMMERCE');
        header2.Add('MERCHANT_CODE', 'AlsaifGallery');
        //header2.Add('Authorization', 'Basic aHBYdXNwUVVqeTBWdDJ1ZnNVR1lZZjF2bGJJYTpwMUpIM05NWWZ0cG1jNEtiZGQ4eG56cWhuamNh');
        //ReqHeader.SetRequestUri('https://sit-b2b.emkanfinance.com.sa/merchant/v1/vouchers/getVoucherDetails');
        if lRetailSetup."Apply Emkan SIT" then begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan SIT Username", lRetailSetup."Emkan SIT Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Get Voucher Details SIT API");
        end else begin
            header2.Add('Authorization', AddHttpBasicAuthHeader(lRetailSetup."Emkan Username", lRetailSetup."Emkan Password"));
            ReqHeader.SetRequestUri(lRetailSetup."Get Voucher Details API");
        end;
        //ReqHeader.SetRequestUri('');//Production API
        ReqHeader.Method('POST');
        client.Send(ReqHeader, response);
        //Response.Content.ReadAs(ResponseText);
        exit(response);

    end;

    procedure RefundProcess(pEmkanRec: Record "Emkan Integration - EDM")
    var
        pHttpResponse: HttpResponseMessage;
        pResponseTXT: Text;
    begin
        pHttpResponse := PreRefund(pEmkanRec."Customer Id");
        pHttpResponse.Content.ReadAs(pResponseTXT);
        if pHttpResponse.IsSuccessStatusCode then begin
            EmkanEntryTable."OTP Id" := ParseJsonText('otpID', pResponseTXT);
            EmkanEntryTable.Modify();
            EPosCtrl.OpenNumericKeyboard('الرقم السري' + '/' + 'OTP Value', '', '#Ins_RefOTP');
        end else
            Message(ParseJsonText('message', pResponseTXT));

    end;

    procedure AddHttpBasicAuthHeader(UserName: Text[50]; Password: Text[50]): text;
    var
        AuthString: Text;
        Base64CU: Codeunit "Base64 Convert";
    begin
        CLEAR(AuthString);
        AuthString := STRSUBSTNO('%1:%2', UserName, Password);
        AuthString := Base64CU.ToBase64(AuthString);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
        exit(AuthString);
    end;

    procedure ParseJsonText(pValueKey: text[20]; pJsonResponseTXT: text): Text
    var
        lJsonToken: JsonToken;
        lJsonObject: JsonObject;
    begin
        Clear(lJsonToken);
        Clear(lJsonObject);
        lJsonObject.ReadFrom(pJsonResponseTXT);
        lJsonObject.get(pValueKey, lJsonToken);
        exit(lJsonToken.AsValue().AsText());
    end;

    procedure ParseJsonDecimal(pValueKey: text[20]; pJsonResponseTXT: text): Decimal
    var
        lJsonToken: JsonToken;
        lJsonObject: JsonObject;
    begin
        Clear(lJsonToken);
        Clear(lJsonObject);
        lJsonObject.ReadFrom(pJsonResponseTXT);
        lJsonObject.get(pValueKey, lJsonToken);
        exit(lJsonToken.AsValue().AsDecimal());
    end;

    procedure ParseJsonObject(pValueKey: text[20]; pJsonResponseTXT: text; pInnerValueKey: Text[20]): text
    var
        lJsonToken: JsonToken;
        lJsonObject: JsonObject;
        linnerJsonToken: JsonToken;
    begin
        Clear(lJsonToken);
        Clear(lJsonObject);
        Clear(linnerJsonToken);
        lJsonObject.ReadFrom(pJsonResponseTXT);
        lJsonObject.get(pValueKey, lJsonToken);
        lJsonToken.AsObject().Get(pInnerValueKey, linnerJsonToken);
        exit(linnerJsonToken.AsValue().AsText());
    end;
}