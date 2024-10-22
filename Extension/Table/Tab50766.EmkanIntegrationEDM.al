table 50766 "Emkan Integration - EDM"
{
    Caption = 'Emkan Integration - EDM';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            DataClassification = ToBeClassified;
        }
        field(4; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Termianl No.';
        }
        field(5; "OTP Id"; Text[200])
        {
            Caption = 'OTP Token';
            DataClassification = ToBeClassified;
        }
        field(6; "OTP Value"; Text[10])
        {
            Caption = 'OTP Value';
            DataClassification = ToBeClassified;
        }
        field(7; "Voucher No."; Text[20])
        {
            Caption = 'Voucher No.';
            DataClassification = ToBeClassified;
        }
        field(8; "Voucher Id"; code[20])
        {
            Caption = 'Voucher Id';
            DataClassification = ToBeClassified;
        }
        field(9; "Application Id"; code[20])
        {
            Caption = 'Application Id';
            DataClassification = ToBeClassified;
        }
        field(10; "Customer Id"; code[20])
        {
            Caption = 'Customer Id';
            DataClassification = ToBeClassified;
        }
        field(11; "Emkan Response"; Text[2048])
        {
            Caption = 'Emkan Response';
            DataClassification = ToBeClassified;
        }

        field(12; "Trans. Date"; Date)
        {
            Caption = 'Trans. Date';
            DataClassification = ToBeClassified;
        }
        field(13; "Voucher Amount"; Decimal)
        {
            Caption = 'Voucher Amount';
            DataClassification = ToBeClassified;
        }
        field(14; "Refund Receipt No."; code[20])
        {
            Caption = 'Refund Receipt No.';
            DataClassification = ToBeClassified;
        }


    }
    keys
    {
        key(PK; "Store No.", "Receipt No.")
        {
            Clustered = true;
        }
    }
}
