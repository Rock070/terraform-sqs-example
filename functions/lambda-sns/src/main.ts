import axios from 'axios';

export const handler = async (event: any): Promise<void> => {
    try {
        console.log("Received SNS event:", JSON.stringify(event, null, 2));

        // 解析 SNS 訊息
        const records = event.Records || [];
        for (const record of records) {
            const snsMessage = record.Sns.Message;
            console.log("處理 SNS 訊息:", snsMessage);

            // 發送到 Slack
            const slackWebhookUrl = process.env.SLACK_WEBHOOK_URL; // 確保配置環境變數
            if (!slackWebhookUrl) {
                throw new Error("SLACK_WEBHOOK_URL 環境變數未設定");
            }

            const slackPayload = {
                text: `來自 SNS 的新訊息：\n${snsMessage}`,
            };

            const response = await axios.post(slackWebhookUrl, slackPayload, {
                headers: {
                    'Content-Type': 'application/json',
                },
            });

            if (response.status !== 200) {
                throw new Error(`Slack Webhook 回應失敗，狀態碼: ${response.status}`);
            }

            console.log("成功發送訊息到 Slack:", snsMessage);
        }
    } catch (error) {
        console.error("處理或發送至 Slack 時發生錯誤:", error);
        throw error;
    }
};
