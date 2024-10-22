tableextension 50766 "EmkRetail Setup Ext." extends "LSC Retail Setup"
{
    fields
    {
        field(50766; "Emkan Username"; Text[100])
        {
            Caption = 'Emkan Username';
            DataClassification = ToBeClassified;
        }
        field(50767; "Emkan Password"; Text[100])
        {
            Caption = 'Emkan Password';
            DataClassification = ToBeClassified;
        }

        field(50768; "Get Voucher Details API"; Text[512])
        {
            DataClassification = ToBeClassified;

        }
        field(50769; "Pre-Redeem API"; Text[512])
        {
            DataClassification = ToBeClassified;
        }
        field(50770; "Redeem API"; Text[512])
        {
            DataClassification = ToBeClassified;
        }
        field(50771; "Pre-Refund API"; Text[512])
        {
            DataClassification = ToBeClassified;
        }
        field(50772; "Refund API"; Text[512])
        {
            DataClassification = ToBeClassified;
        }
        field(50773; "Emkan SIT Username"; Text[100])
        {
            Caption = 'Emkan SIT Username';
            DataClassification = ToBeClassified;
        }
        field(50774; "Emkan SIT Password"; Text[100])
        {
            Caption = 'Emkan SIT Password';
            DataClassification = ToBeClassified;
        }
        field(50775; "Get Voucher Details SIT API"; Text[512])
        {
            DataClassification = ToBeClassified;

        }
        field(50776; "Pre-Redeem SIT API"; Text[512])
        {
            DataClassification = ToBeClassified;
        }
        field(50777; "Redeem SIT API"; Text[512])
        {
            DataClassification = ToBeClassified;
        }
        field(50778; "Pre-Refund SIT API"; Text[512])
        {
            DataClassification = ToBeClassified;
        }
        field(50779; "Refund SIT API"; Text[512])
        {
            DataClassification = ToBeClassified;
        }
        field(50780; "Emkan Tender Type"; Text[10])
        {
            Caption = 'Emkan Tender Type';
            DataClassification = ToBeClassified;
            TableRelation = "LSC Tender Type Setup".Code;
        }
        field(50781; "Apply Emkan SIT"; Boolean)
        {
            DataClassification = ToBeClassified;
        }


    }
}