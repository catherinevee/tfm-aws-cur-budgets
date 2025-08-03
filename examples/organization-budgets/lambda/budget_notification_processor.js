const https = require('https');
const url = require('url');

exports.handler = async (event) => {
    try {
        // Parse SNS message
        const message = event.Records[0].Sns.Message;
        const budgetNotification = JSON.parse(message);
        
        // Create Slack message
        const slackMessage = formatSlackMessage(budgetNotification);
        
        // Send to Slack
        await sendToSlack(process.env.SLACK_WEBHOOK_URL, slackMessage);
        
        return {
            statusCode: 200,
            body: 'Notification sent successfully'
        };
    } catch (error) {
        console.error('Error processing budget notification:', error);
        throw error;
    }
};

function formatSlackMessage(notification) {
    const account = notification.Account;
    const budgetName = notification.BudgetName;
    const actualSpend = notification.ActualSpend;
    const budgetLimit = notification.BudgetLimit;
    const forecastedSpend = notification.ForecastedSpend;
    const threshold = notification.Threshold;
    const unit = notification.Unit;

    const color = getAlertColor(threshold);
    
    return {
        attachments: [{
            color: color,
            title: `AWS Budget Alert: ${budgetName}`,
            fields: [
                {
                    title: "Account",
                    value: account,
                    short: true
                },
                {
                    title: "Environment",
                    value: process.env.ENVIRONMENT,
                    short: true
                },
                {
                    title: "Budget Limit",
                    value: `${budgetLimit} ${unit}`,
                    short: true
                },
                {
                    title: "Actual Spend",
                    value: `${actualSpend} ${unit}`,
                    short: true
                },
                {
                    title: "Forecasted Spend",
                    value: `${forecastedSpend} ${unit}`,
                    short: true
                },
                {
                    title: "Threshold",
                    value: `${threshold}%`,
                    short: true
                }
            ],
            footer: "AWS Budget Notification",
            ts: Math.floor(Date.now() / 1000)
        }]
    };
}

function getAlertColor(threshold) {
    if (threshold >= 90) return "#ff0000";      // Red for critical
    if (threshold >= 80) return "#ffa500";      // Orange for warning
    return "#36a64f";                           // Green for info
}

async function sendToSlack(webhookUrl, message) {
    const parsedUrl = url.parse(webhookUrl);
    
    const options = {
        hostname: parsedUrl.hostname,
        path: parsedUrl.path,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    };

    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                if (res.statusCode === 200) {
                    resolve(data);
                } else {
                    reject(new Error(`Status Code: ${res.statusCode}, Response: ${data}`));
                }
            });
        });
        
        req.on('error', (error) => {
            reject(error);
        });
        
        req.write(JSON.stringify(message));
        req.end();
    });
}
