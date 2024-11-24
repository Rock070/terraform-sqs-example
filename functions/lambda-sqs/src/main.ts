import { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } from "@aws-sdk/client-sqs";
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";

type MessageBody = {
  message: string
}

const sqsClient = new SQSClient({ region: "us-west-2" });

export async function handler(): Promise<void> {
  const queueUrl = process.env.SQS_QUEUE_URL as string;

  try {
    // 從 SQS 中拉取訊息
    const receiveMessageResult = await sqsClient.send(
      new ReceiveMessageCommand({
        QueueUrl: queueUrl,
        MaxNumberOfMessages: 10,
        WaitTimeSeconds: 10,
      })
    );

    const messages = receiveMessageResult.Messages!

    if (messages) {
      for (const message of messages) {
        try {
          const messageBody: MessageBody = JSON.parse(message.Body!);
          console.log("Processing message:", messageBody);

          if (messageBody.message && messageBody.message.includes("fail")) {
            throw new Error("Processing failed.");
          }

          // 完成後，刪除消息
          await deleteMessage(message.ReceiptHandle!, queueUrl);
          console.log("Message successfully processed and deleted.");

        } catch (processingError) {
          console.error("Error processing message:", processingError);
          // 如果邏輯失敗，可以選擇不刪除消息，這樣訊息會在稍後重試
        }
      }
    } else {
      console.log("No messages to process.");
    }
    await notify('成功')
  } catch (error) {
    await notify(error)
    console.error("Error receiving messages from SQS:", error);
  }
}

async function deleteMessage(receiptHandle: string, queueUrl: string) {
  const deleteCommand = new DeleteMessageCommand({
    QueueUrl: queueUrl,
    ReceiptHandle: receiptHandle,
  });

  try {
    await sqsClient.send(deleteCommand);
    console.log("Message deleted from SQS.");
  } catch (error) {
    console.error("Error deleting message from SQS:", error);
    throw error;
  }
}


const notify = async (event: any): Promise<void> => {
  const snsClient = new SNSClient({ region: "us-west-2" });

  try {
      console.log("Received event:", JSON.stringify(event, null, 2));

      // 處理邏輯
      const processedResult = `處理完成，輸入為：${JSON.stringify(event)}`;

      // 發送到 SNS 主題
      const topicArn = process.env.SNS_TOPIC_ARN; // 確保配置環境變數
      if (!topicArn) {
          throw new Error("SNS_TOPIC_ARN 環境變數未設定");
      }

      const publishCommand = new PublishCommand({
          TopicArn: topicArn,
          Message: processedResult,
      });

      const response = await snsClient.send(publishCommand);

      console.log("成功發送訊息到 SNS:", processedResult);
      console.log("SNS Response:", response);
  } catch (error) {
      console.error("處理或發送至 SNS 時發生錯誤:", error);
      throw error;
  }
};