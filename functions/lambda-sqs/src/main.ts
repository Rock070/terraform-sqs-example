import { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } from "@aws-sdk/client-sqs";

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

    console.log("🚀 ~ handler ~ receiveMessageResult:", receiveMessageResult, typeof receiveMessageResult)

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
  } catch (error) {
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
