const https = require('https');

const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-2.5-flash';
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

const extractText = (payload) => {
  const parts = payload?.candidates?.[0]?.content?.parts || [];
  return parts.map((part) => part.text || '').join('').trim();
};

const httpsPost = (url, body) => {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const options = {
      hostname: u.hostname,
      port: 443,
      path: u.pathname + u.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      rejectUnauthorized: false, // Bypass CRYPT_E_REVOCATION_OFFLINE
    };

    const req = https.request(options, (res) => {
      let chunks = [];
      res.on('data', (d) => chunks.push(d));
      res.on('end', () => {
        const bodyStr = Buffer.concat(chunks).toString();
        resolve({
          ok: res.statusCode >= 200 && res.statusCode < 300,
          status: res.statusCode,
          text: async () => bodyStr,
          json: async () => {
            try {
              return JSON.parse(bodyStr);
            } catch (e) {
              return {};
            }
          },
        });
      });
    });

    req.on('error', (e) => reject(e));
    req.write(JSON.stringify(body));
    req.end();
  });
};

exports.generateAdvisorSummary = async (answers, recommendation) => {
  if (!GEMINI_API_KEY) {
    return recommendation.summary;
  }

  const prompt = `You are Naddefli's friendly home-cleaning advisor.
Write exactly 2 short, helpful sentences explaining why this cleaning plan fits the customer's home.
Do NOT change the service type, hours, or price. Keep it practical and reassuring.

Customer answers:
- Property: ${answers.propertyType}
- Bedrooms: ${answers.bedrooms}
- Bathrooms: ${answers.bathrooms}
- Kitchens: ${answers.kitchens}
- Situation: ${answers.situation}
- Pets: ${answers.pets}

Recommended plan:
- Service: ${recommendation.cleaningLabel}
- Duration: ${recommendation.durationHours} hours
- Estimated price: $${recommendation.estimatedPrice}`;

  try {
    const response = await httpsPost(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`,
      {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 256,
        },
      }
    );

    if (!response.ok) {
      const errorBody = await response.text();
      console.warn('Gemini advisor summary failed:', response.status, errorBody);
      return recommendation.summary;
    }

    const data = await response.json();
    const text = extractText(data);
    return text || recommendation.summary;
  } catch (error) {
    console.warn('Gemini advisor summary error:', error.message);
    return recommendation.summary;
  }
};
