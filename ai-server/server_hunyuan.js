import 'dotenv/config';
import express from "express";
import cors from "cors";

import { genkit } from "genkit";
import { z } from "zod";

import cloudbaseSDK from "@cloudbase/node-sdk";
import tcb from '@cloudbase/node-sdk'
const huanyuan = tcb.init({ 
  env: process.env.CLOUDBASE_ENV_ID , 
  secretId: process.env.CLOUDBASE_SECRET_ID, 
  secretKey: process.env.CLOUDBASE_SECRET_KEY,
  timeout: 60000,
  region: 'ap-shanghai'
})


// ===== 初始化 =====
const app = express();
app.use(cors());
app.use(express.json());

const hunyuan_ai = huanyuan.ai();
const model = hunyuan_ai.createModel("hunyuan-exp");

// ===== 初始化 Genkit =====
const ai = genkit();

// 获取 文档数据库实例
const db = huanyuan.database();

// ===== 封装混元调用 =====
async function callHunyuan(messages) {
  const res = await model.generateText({
    model: "hunyuan-2.0-instruct-20251111",
    messages,
  });

  return res.text;
}

// ===== Genkit Flow（核心）=====
const analyzeFlow = ai.defineFlow(
  {
    name: "analyzeFlow",
    inputSchema: z.object({
      query: z.string(),
    }),
    outputSchema: z.string(),
  },
  async ({ query }) => {
    const messages = [
      {
        role: "system",
        content: "你是材料行业专家，擅长分析玻璃纤维、FRP、复合材料。",
      },
      {
        role: "user",
        content: `
请分析以下问题：

${query}

请按结构输出：
【结论】
【原因】
【建议】
`,
      },
    ];

    const result = await callHunyuan(messages);

    return result;
  }
);

// ===== API =====
app.post("/ai", async (req, res) => {
  try {
    const { query } = req.body;

    const result = await analyzeFlow({ query });

    res.json({ result });
  } catch (e) {
    console.error("❌ AI error:", e);
    res.status(500).json({ error: "AI调用失败" });
  }
});

// ===== 流式版本（高级）=====
app.post("/ai-stream", async (req, res) => {
  const { query } = req.body;

  res.setHeader("Content-Type", "text/plain; charset=utf-8");
  res.setHeader("Transfer-Encoding", "chunked");

  try {
    const stream = await model.streamText({
      model: "hunyuan-2.0-instruct-20251111",
      messages: [
        {
          role: "system",
          content: "你是材料行业专家",
        },
        {
          role: "user",
          content: query,
        },
      ],
    });

    for await (let chunk of stream.textStream) {
      res.write(chunk);
    }

    res.end();
  } catch (e) {
    console.error("❌ stream error:", e);
    res.end("error");
  }
});


// API接口
// app.get("/api/experts", async (req, res) => {
//   try {
//     const { collection } = req.query; // ⭐ 获取参数

//     // ✅ 参数校验（非常重要）
//     if (!collection) {
//       return res.status(400).json({
//         success: false,
//         error: "缺少 collection 参数",
//       });
//     }

//     const result = await db
//       .collection(collection) // ⭐ 动态集合
//       .limit(10)
//       .get();

//     console.log("查询集合:", collection);
//     console.log("查询结果:", result);

//     res.json({
//       success: true,
//       data: result.data,
//     });
//   } catch (err) {
//     res.status(500).json({
//       success: false,
//       error: err.message,
//     });
//   }
// });

app.get("/api/experts", async (req, res) => {
  try {
    const { collection } = req.query;

    // ⭐ 分页参数（默认值）
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    // ✅ 参数校验
    if (!collection) {
      return res.status(400).json({
        success: false,
        error: "缺少 collection 参数",
      });
    }

    if (page < 1 || limit < 1) {
      return res.status(400).json({
        success: false,
        error: "page 和 limit 必须大于 0",
      });
    }

    const skip = (page - 1) * limit;

    // ⭐ 查询数据（多查一条判断是否还有下一页）
    const result = await db
      .collection(collection)
      .skip(skip)
      .limit(limit + 1) // ⭐ 关键：多查1条
      .get();

    const list = result.data || [];

    const hasMore = list.length > limit;

    // ⭐ 只返回 limit 条
    const data = hasMore ? list.slice(0, limit) : list;

    console.log("集合:", collection, "页:", page, "数量:", data.length);

    console.log(data[0])
    

    res.json({
      success: true,
      data,
      page,
      limit,
      hasMore,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

app.get("/api/meta", async (req, res) => {
  try {
    // ⭐ 获取参数（带默认值）
    const { page = 1, limit = 10 } = req.query;

    const pageSize = Math.max(1, Math.min(100, Number(limit))); // 限制最大100
    const pageIndex = Math.max(1, Number(page));

    const skip = (pageIndex - 1) * pageSize;

    // ⭐ 查询数据
    const result = await db
      .collection("collections_meta")
      .skip(skip)
      .limit(pageSize)
      .get();

    // ⭐ 可选：返回总数（用于判断是否还有更多）
    const countRes = await db.collection("collections_meta").count();
    const total = countRes.total;

    res.json({
      success: true,
      data: result.data,
      page: pageIndex,
      limit: pageSize,
      total,
      hasMore: skip + result.data.length < total, // ⭐ 是否还有数据
    });

    console.log("分页查询:", {
      page: pageIndex,
      limit: pageSize,
      returned: result.data.length,
      total,
    });

  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});



// ===== 启动 =====
app.listen(3000, () => {
  console.log("✅ Genkit + Hunyuan server: http://localhost:3000");
});

// import 'dotenv/config';
// import express from "express";
// import cors from "cors";



// import cloudbaseSDK from "@cloudbase/node-sdk";
// import tcb from '@cloudbase/node-sdk'
// const huanyuan = tcb.init({ 
//   env: process.env.CLOUDBASE_ENV_ID , 
//   secretId: process.env.CLOUDBASE_SECRET_ID, 
//   secretKey: process.env.CLOUDBASE_SECRET_KEY,
//   timeout: 60000,
//   region: 'ap-shanghai'
// })
// const ai = huanyuan.ai()


// const app = express();
// app.use(cors());
// app.use(express.json());

// console.log("envId =", process.env.CLOUDBASE_ENV_ID);
// console.log("secretId =", process.env.CLOUDBASE_SECRET_ID);
// console.log("secretKey =", process.env.CLOUDBASE_SECRET_KEY); 

// // 初始化
// const model = ai.createModel("hunyuan-exp");


// // ===== 普通返回（推荐先用这个）=====
// app.post("/ai", async (req, res) => {
//   const { query } = req.body;

//   res.setHeader("Content-Type", "text/plain; charset=utf-8");
//   res.setHeader("Transfer-Encoding", "chunked");

//   try {
//     const result = await model.generateText({
//       model: "hunyuan-2.0-instruct-20251111",
//       messages: [
//         {
//           role: "system",
//           content: "你是材料行业专家，擅长分析玻璃纤维、FRP、复合材料。",
//         },
//         {
//           role: "user",
//           content: query,
//         },
//       ],
//     });

//     res.json({
//       result: result.text,
//     });
//   } catch (err) {
//     console.error("❌ AI error:", err);
//     res.status(500).json({ error: "AI调用失败" });
//   }
// });

// app.post("/ai-stream", async (req, res) => {
//   const { query } = req.body;

//   res.setHeader("Content-Type", "text/plain; charset=utf-8");
//   res.setHeader("Transfer-Encoding", "chunked");

//   try {
//     const stream = await model.streamText({
//       model: "hunyuan-2.0-instruct-20251111",
//       messages: [
//         {
//           role: "system",
//           content: "你是材料行业专家，请给出结构化分析。",
//         },
//         {
//           role: "user",
//           content: query,
//         },
//       ],
//     });

//     for await (let chunk of stream.textStream) {
//       res.write(chunk); // 👉 实时返回
//     }

//     res.end();
//   } catch (err) {
//     console.error("❌ stream error:", err);
//     res.end("error");
//   }
// });

// app.listen(3000, () => {
//   console.log("✅ Hunyuan API server: http://localhost:3000");
// });