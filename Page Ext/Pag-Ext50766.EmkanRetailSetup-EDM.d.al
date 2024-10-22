pageextension 50766 "EmkanRetail Setup Ext." extends "LSC Retail Setup"
{
    layout
    {
        addlast(General)
        {


        }
        addafter(General)
        {
            group("Emkan Configurations")
            {
                field("Apply Emkan SIT"; Rec."Apply Emkan SIT")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Emkan Tender Type"; Rec."Emkan Tender Type")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }

            }
            group(SIT)
            {
                Caption = 'Emkan SIT Configurations';
                Visible = Rec."Apply Emkan SIT";
                field("Emkan SIT Username"; "Emkan SIT Username")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Emkan SIT Password"; "Emkan SIT Password")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Get Voucher Details SIT API"; "Get Voucher Details SIT API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Pre-Redeem SIT API"; "Pre-Redeem SIT API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Redeem SIT API"; "Redeem SIT API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Pre-Refund SIT API"; "Pre-Refund SIT API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Refund SIT API"; "Refund SIT API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }

            }
            group(Production)
            {
                Caption = 'Emkan Production Configurations';
                Visible = not Rec."Apply Emkan SIT";
                field("Emkan Username"; "Emkan Username")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Emkan Password"; "Emkan Password")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Get Voucher Details API"; "Get Voucher Details API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Pre-Redeem API"; "Pre-Redeem API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Redeem API"; "Redeem API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Pre-Refund API"; "Pre-Refund API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }
                field("Refund API"; "Refund API")
                {
                    ApplicationArea = all;
                    Visible = true;
                    Editable = true;
                }



            }
        }
    }
    actions
    {

    }
}
