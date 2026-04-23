import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import "theme.js" as AppTheme


Dialog {
    id: newPortfolioDialog
    modal: true
    focus: true
    title: "Create New Portfolio"

    property alias portfolioNameField: newPortfolioName
    signal portfolioCreated(string name)

    Column {
        spacing: units.gu(1)
        padding: units.gu(1)

        TextField {
            id: newPortfolioName
            text: i18n.tr("Enter portfolio name")
        }

        Row {
            spacing: units.gu(2)
            Button {
                text: i18n.tr("Create")
                onClicked: {
                    if (newPortfolioName.text.length > 0) {
                        portfolioCreated(newPortfolioName.text);
                        newPortfolioName.text = "";
                        newPortfolioDialog.close();
                    }
                }
            }
            Button {
                text: i18n.tr("Cancel")
                onClicked: newPortfolioDialog.close()
            }
        }
    }
}
