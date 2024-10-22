tableextension 50767 "Trans. Payment Entry Emkan" extends "LSC Trans. Payment Entry"
{
    fields
    {
        field(50767; "Emkan Voucher no."; Text[20])
        {
            Caption = 'Emkan Voucher no.';
            DataClassification = ToBeClassified;
            Editable = true;
            Enabled = true;
        }
        field(50768; "Emkan Voucher Id"; code[20])
        {
            Caption = 'Emkan Voucher Id';
            DataClassification = ToBeClassified;
            Editable = true;
            Enabled = true;
        }
    }
}
