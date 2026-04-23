import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import "datastore.js" as DB
import "theme.js" as AppTheme

Page {
    id: portfolioPage

    header: PageHeader {
        title: "Portfolio"
        ActionBar {
            numberOfSlots: 2
            anchors.right: parent.right
            actions: [
                Action {
                    iconName: "add"
                    text: i18n.tr("Portfolio")
                    onTriggered: newPortfolioDialog.open()
                },
                Action {
                    iconName: "delete"
                    text: i18n.tr("Portfolio")
                    onTriggered: {
                        if (selectedPortfolio !== -1) {
                            DB.deletePortfolio(selectedPortfolio)
                            reloadPortfolios()
                        }
                    }
                }

            ]
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: units.gu(1)
        contentHeight: contentColumn.implicitHeight
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: units.gu(2)

            // === Top row with Combo + Buttons ===
            // === Top row with Combo + Total ===
            Row {
                id: topRow
                spacing: units.gu(1)
                width: parent.width

                ComboBox {
                    id: portfolioSelector
                    width: parent.width * 0.4
                    model: portfolioNames
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < portfolioIds.length) {
                            selectedPortfolio = portfolioIds[currentIndex];
                            loadHoldingsForPortfolio(selectedPortfolio);
                        } else {
                            selectedPortfolio = -1;
                            holdingsModel = [];
                        }
                    }
                }
                Button {
                    text: i18n.tr("Add Coin")
                    enabled: (selectedPortfolio !== -1)
                    onClicked: {
                        addCoinDialog.open()
                    }
                }
            }

            // === Holdings Header ===
            Text {
                text: i18n.tr("Your Holdings Worth") + " (€" + totalValue.toFixed(2) + ")"
                font.bold: true
                font.pixelSize: units.gu(2.2)
            }

            /*  PortfolioChart{
                id: historyChart
                  height: units.gu(30)
                  width: parent.width
            }*/

            LomiriListView {
                id: holdingsList
                width: parent.width
                height: units.gu(60)
                spacing: units.gu(1)
                model: holdingsModel

                delegate: PortfolioItem {
                    coinName: modelData.coin_name
                    coinSymbol: modelData.coin_symbol
                    quantity: modelData.amount
                    price: modelData.current_price
                    total_value: modelData.total_value
                    coinImage: modelData.image_url
                    recordId: modelData.id   // Make sure you pass this from your DB!
                    delta:modelData.delta
                    delta_percentage:modelData.delta_percent
                    onEditRequested: {
                        console.log("Edit requested for record:", recordId)
                        addCoinDialog.editMode = true;
                        addCoinDialog.editingSymbol = modelData.coin_symbol;
                        addCoinDialog.symbolField.text = modelData.coin_symbol;
                        addCoinDialog.amountField.text = modelData.amount.toString();
                        addCoinDialog.open();
                    }

                    onDeleteRequested: {
                        if (selectedPortfolio !== -1) {
                            DB.deleteHolding(selectedPortfolio, coinSymbol);
                            loadHoldingsForPortfolio(selectedPortfolio);
                        }
                    }
                }
            }

        }
    }

    // === Dialog: New Portfolio ===
    NewPortfolioDialog {
        id: newPortfolioDialog
        onPortfolioCreated: {
            console.log("Saving " + name);
            DB.addPortfolio(name);
            reloadPortfolios();
        }
    }

    // === Dialog: Add Coin ===
    AddCoinDialog {
        id: addCoinDialog

        onCoinAdded: {
            if (selectedPortfolio !== -1) {
                DB.addHolding(selectedPortfolio, symbol, amount);
                loadHoldingsForPortfolio(selectedPortfolio);
            }
        }

        onCoinEdited: {
            if (selectedPortfolio !== -1) {
                DB.addHolding(selectedPortfolio, symbol, amount,true);
                loadHoldingsForPortfolio(selectedPortfolio);
            }
        }
    }


    // === Properties ===
    property var portfolioNames: []
    property var portfolioIds: []
    property int selectedPortfolio: -1
    property var holdingsModel: []
    property real totalValue: 0.0

    // === Logic ===
    Component.onCompleted: reloadPortfolios()

    function reloadPortfolios() {
        var portfolios = DB.getPortfolios();
        portfolioNames = portfolios.map(p => p.name);
        portfolioIds = portfolios.map(p => p.id);
        if (portfolioIds.length > 0) {
            selectedPortfolio = portfolioIds[0];
            portfolioSelector.currentIndex = 0;
            loadHoldingsForPortfolio(selectedPortfolio);

        } else {
            holdingsModel = [];
        }
    }

    function loadHoldingsForPortfolio(portfolioId) {
        var holdings = DB.getHoldings(portfolioId);
        holdingsModel = holdings;

        // Compute total value from holdings
        var total = 0.0;
        for (var i = 0; i < holdings.length; i++) {
            var val = parseFloat(holdings[i].total_value);
            if (!isNaN(val)) {
                total += val;
            }
        }
        totalValue = total;
    }

}
