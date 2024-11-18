import { SQSClient, SendMessageBatchCommand } from '@aws-sdk/client-sqs';

const sqsClient = new SQSClient({ region: 'us-west-2' });

export const handler = async (event: any) => {
  const messages = event.messages;

  if (!Array.isArray(messages) || messages.length === 0) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'No messages provided or invalid format' }),
    };
  }

  const entries = messages.map((message: string, index: number) => ({
    Id: `msg-${index + 1}`,  // 唯一的訊息 ID
    MessageBody: JSON.stringify(message),
    MessageGroupId: 'test-11-17', // 用於 FIFO 隊列的群組 ID
    MessageDeduplicationId: Math.random().toString(), // 用於 FIFO 隊列的去重 ID
  }));

  // 批量發送的參數
  const params = {
    QueueUrl: process.env.SQS_QUEUE_URL!,
    Entries: entries, // 批量消息條目
  };

  try {
    // 使用 SQS 發送批量消息
    const command = new SendMessageBatchCommand(params);
    const data = await sqsClient.send(command);
    console.log('Messages sent to SQS:', data.Successful);

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Messages sent to SQS successfully',
        successfulMessages: data.Successful,
      }),
    };
  } catch (error) {
    console.error('Error sending messages to SQS', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to send messages to SQS' }),
    };
  }
};
