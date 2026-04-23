import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
Dialog {
    id: addCoinDialog
    modal: true
    focus: true
    title: editMode ? "Edit Coin Holding" : "Add Coin to Portfolio"

    // Properties
    property bool editMode: false
    property string editingSymbol: ""
    property alias symbolField: coinSymbolField
    property alias amountField: coinAmountField
    signal coinAdded(string symbol, real amount)
    signal coinEdited(string symbol, real amount)

    Column {
        spacing: units.gu(1)
        padding: units.gu(1)

        TextField {
            id: coinSymbolField
            placeholderText: i18n.tr("Coin Symbol (e.g. BTC)")
            readOnly: editMode  // make symbol non-editable in edit mode
        }

        TextField {
            id: coinAmountField
            placeholderText: i18n.tr("Amount (e.g. 2.5)")
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }

        Row {
            spacing: units.gu(2)

            Button {
                text: editMode ? "Update" : "Add"
                onClicked: {
                    if (coinSymbolField.text && coinAmountField.text) {
                        var symbol = coinSymbolField.text;
                        var amount = parseFloat(coinAmountField.text);
                        if (editMode)
                            coinEdited(symbol, amount);
                        else
                            coinAdded(symbol, amount);

                        // Reset and close
                        coinSymbolField.text = "";
                        coinAmountField.text = "";
                        editMode = false;
                        editingSymbol = "";
                        addCoinDialog.close();
                    }
                }
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: {
                    coinSymbolField.text = "";
                    coinAmountField.text = "";
                    editMode = false;
                    editingSymbol = "";
                    addCoinDialog.close();
                }
            }
        }
    }
}
