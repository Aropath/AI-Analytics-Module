import axios from "axios";

const notificationApi = axios.create({
  baseURL: "http://localhost:5000/api/notifications",
});

export async function createChecklistNotification(
  projectId: string,
  titles: string[]
): Promise<void> {
  if (titles.length === 0) return;

  const summary =
    titles.length <= 3
      ? titles.join(", ")
      : `${titles.slice(0, 3).join(", ")} and ${titles.length - 3} more`;

  try {
    console.log("Sending notification to Notification API...");
    await notificationApi.post("/internal", {
      projectId,
      category: "Checklist",
      type: "created",
      title: "New action items for you have been added to the checklist",
      summary,
      priority: "medium",
      source: "Checklist Service",
      targetPage: "/dashboard/checklist",
      details: {
        itemCount: titles.length,
        actionItems: titles,
      },
    });

    console.log("Checklist notification created successfully.");
  } catch (error: any) {
    console.error(
      "Failed to create checklist notification:",
      error.response?.data || error.message
    );
  }
}