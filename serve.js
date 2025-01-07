// server.js
const express = require('express');
const mysql = require('mysql');
const bcrypt = require('bcryptjs');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000; 

app.use(cors());
app.use(bodyParser.json());


const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'gogoapp'
});

db.connect(err => {
    if (err) {
        console.error('Database connection failed:', err);
        return;
    }
    console.log('Database connected!');
});

// ----------------------------------------------------------------------------用戶管理 API-----------------------------------------------------------
// 1. 获取所有用户
app.get('/users', (req, res) => {
  const sql = 'SELECT id, name, email, phone, job, gender FROM users';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Database query failed:', err);
      return res.status(500).json({ status: 'error', message: 'Failed to fetch users' });
    }
    res.json({ status: 'success', users: results });
  });
});

app.get('/users/:name', (req, res) => {
  const { name } = req.params;
  console.log(`Received request for user name: ${name}`); // 打印请求的用户名

  const sql = 'SELECT id, name, email, phone, job, gender FROM users WHERE name = ?';
  db.query(sql, [name], (err, result) => {
    if (err) {
      console.error('Database query failed:', err);
      return res.status(500).json({ status: 'error', message: 'Failed to fetch user' });
    }
    console.log(`Query result: ${JSON.stringify(result)}`); // 打印查询结果

    if (result.length === 0) {
      return res.status(404).json({ status: 'error', message: 'User not found' });
    }
    res.json({ status: 'success', user: result[0] });
  });
});

// ----------------------------------------------------------------------------登錄-----------------------------------------------------------
app.post('/login', (req, res) => {
    const { username, password } = req.body;

    // 檢查請求數據是否完整
    if (!username || !password) {
        return res.status(400).send({
            status: 'error',
            message: 'Username and password are required.',
        });
    }

    // 查詢用戶的 id 和加密的密碼
    const sql = `SELECT id, password FROM users WHERE name = ${mysql.escape(username)}`;
    db.query(sql, (err, result) => {
        if (err) {
            console.error('Database query error:', err); // 輸出詳細的錯誤日誌
            return res.status(500).send({
                status: 'error',
                message: 'Internal server error. Please try again later.',
            });
        }

        // 檢查是否找到用戶
        if (result.length === 0) {
            return res.status(404).send({
                status: 'error',
                message: 'User not found.',
            });
        }

        // 獲取用戶數據
        const userId = result[0].id; // 用戶 id
        const hashedPassword = result[0].password; // 加密的密碼

        // 比較密碼
        bcrypt.compare(password, hashedPassword, (err, isMatch) => {
            if (err) {
                console.error('Password comparison error:', err); // 輸出詳細的錯誤日誌
                return res.status(500).send({
                    status: 'error',
                    message: 'Internal server error. Please try again later.',
                });
            }

            if (isMatch) {
                // 如果密碼匹配，返回用戶 id
                return res.send({
                    status: 'success',
                    message: 'Login successful.',
                    userId: userId.toString(), // 確保 userId 是字符串格式
                });
            } else {
                // 密碼錯誤
                return res.status(401).send({
                    status: 'error',
                    message: 'Password incorrect.',
                });
            }
        });
    });
});
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
// ----------------------------------------------------------------------------注冊-----------------------------------------------------------
app.post('/register', (req, res) => {
    const { name, password, email, phone, job, gender } = req.body;
    console.log('Received data:', req.body);

if (!name || !password || !email || !gender) {
    return res.status(400).json({ status: 'error', message: 'Required fields are missing' });
}

const checkUserSql = `SELECT id FROM users WHERE name = ${mysql.escape(name)}`;
db.query(checkUserSql, (err, result) => {
    if (err) {
        console.error('Error checking user:', err);
        return res.status(500).json({ status: 'error', message: 'Error checking user: ' + err.message });
    }
    if (result.length > 0) {
        return res.status(409).json({ status: 'error', message: 'Username already exists' });
    }
    bcrypt.hash(password, 10, (err, hashedPassword) => {
        if (err) {
            console.error('Error hashing password:', err);
            return res.status(500).json({ status: 'error', message: 'Error hashing password: ' + err.message });
        }

        const insertSql = `INSERT INTO users (name, password, email, phone, job, gender) VALUES (${mysql.escape(name)}, ${mysql.escape(hashedPassword)}, ${mysql.escape(email)}, ${mysql.escape(phone)}, ${mysql.escape(job)}, ${mysql.escape(gender)})`;
        db.query(insertSql, (err, result) => {
            if (err) {
                console.error('Error inserting user:', err);
                return res.status(500).json({ status: 'error', message: 'Error inserting user: ' + err.message });
            }
            res.status(201).json({ status: 'success', message: 'User registered successfully' });
        });
    });
});
});
// ----------------------------------------------------------------------------圖片引入-----------------------------------------------------------
app.get('/images', (req, res) => {
    console.log('Fetching images...');

    const sql = 'SELECT * FROM images';
    db.query(sql, (err, results) => {
        if (err) {
           
            console.log('Database query failed:', err);
            return res.status(500).send(err);
        }

        console.log('Database query successful:', results);

      
        const urls = results.map(item => item.url);
        console.log('Image URLs:', urls);

        res.json(urls);
    });
});
// ----------------------------------------------------------------------------商品引入-----------------------------------------------------------
app.get('/products', (req, res) => {
    const sql = 'SELECT * FROM products';
    db.query(sql, (err, results) => {
        if (err) {
            console.error('Database query failed:', err);
            return res.status(500).send({ status: 'error', message: err.message });
        }
        console.log('Products fetched successfully:', results);
        res.json(results);
    });
});
app.get('/products/search', (req, res) => {
  const searchQuery = req.query.search;

  if (!searchQuery) {
      return res.status(400).send({ status: 'error', message: 'Search query is required' });
  }

  const sql = 'SELECT id, image_url, name, price FROM products WHERE name LIKE ? OR tags LIKE ?';
  const searchTerm = `%${searchQuery}%`;

  db.query(sql, [searchTerm, searchTerm], (err, results) => {
      if (err) {
          console.error('Database query failed:', err);
          return res.status(500).send({ status: 'error', message: 'Database error' });
      }

      res.json({ status: 'success', products: results });
  });
});
//--------------------------------------------------------------------商品引入type vegetable----------------------------------------
app.get('/products/type/vegetable', (req, res) => {
  const sql = 'SELECT * FROM products WHERE type = "vegetable"';
  db.query(sql, (err, results) => {
      if (err) {
          console.error('Database query failed:', err);
          return res.status(500).send({ status: 'error', message: 'Database query failed: ' + err.message });
      }
      console.log('Products with tag "off" fetched successfully:', results);
      res.json(results);
  });
});
//--------------------------------------------------------------------商品引入type drink----------------------------------------
app.get('/products/type/drink', (req, res) => {
  const sql = 'SELECT * FROM products WHERE type = "drink"';
  db.query(sql, (err, results) => {
      if (err) {
          console.error('Database query failed:', err);
          return res.status(500).send({ status: 'error', message: 'Database query failed: ' + err.message });
      }
      console.log('Products with tag "off" fetched successfully:', results);
      res.json(results);
  });
});
//--------------------------------------------------------------------商品引入type food----------------------------------------
app.get('/products/type/food', (req, res) => {
  const sql = 'SELECT * FROM products WHERE type = "food"';
  db.query(sql, (err, results) => {
      if (err) {
          console.error('Database query failed:', err);
          return res.status(500).send({ status: 'error', message: 'Database query failed: ' + err.message });
      }
      console.log('Products with tag "off" fetched successfully:', results);
      res.json(results);
  });
});
//--------------------------------------------------------------------商品引入type life----------------------------------------
app.get('/products/type/life', (req, res) => {
  const sql = 'SELECT * FROM products WHERE type = "life"';
  db.query(sql, (err, results) => {
      if (err) {
          console.error('Database query failed:', err);
          return res.status(500).send({ status: 'error', message: 'Database query failed: ' + err.message });
      }
      console.log('Products with tag "off" fetched successfully:', results);
      res.json(results);
  });
});
// ----------------------------------------------------------------------------商品off引入-----------------------------------------------------------

app.get('/products/off', (req, res) => {
    const sql = 'SELECT * FROM products WHERE tags = "off"';
    db.query(sql, (err, results) => {
        if (err) {
            console.error('Database query failed:', err);
            return res.status(500).send({ status: 'error', message: 'Database query failed: ' + err.message });
        }
        console.log('Products with tag "off" fetched successfully:', results);
        res.json(results);
    });
});

// ----------------------------------------------------------------------------商品tag2引入-----------------------------------------------------------

app.get('/products/tag', (req, res) => {
    const sql = 'SELECT * FROM products WHERE tags = "tag2"';
    db.query(sql, (err, results) => {
        if (err) {
            console.error('Database query failed:', err);
            return res.status(500).send({ status: 'error', message: 'Database query failed: ' + err.message });
        }
        console.log('Products with tag "off" fetched successfully:', results);
        res.json(results);
    });
});
// ----------------------------------------------------------------------------菜式引入----------------------------------------------------------


app.get('/random-dishes', (req, res) => {
    const vegetableQuery = `
        SELECT d.name as dish_name, d.recipe, 
               GROUP_CONCAT(p.name) as product_names, 
               GROUP_CONCAT(p.price) as product_prices,
               GROUP_CONCAT(p.image_url) as product_images
        FROM dishes d
        JOIN dish_products dp ON d.id = dp.dish_id
        JOIN products p ON dp.product_id = p.id
        WHERE d.type='素'
        GROUP BY d.id 
        ORDER BY RAND() LIMIT 2`;

    const meatQuery = `
        SELECT d.name as dish_name, d.recipe, 
               GROUP_CONCAT(p.name) as product_names, 
               GROUP_CONCAT(p.price) as product_prices,
               GROUP_CONCAT(p.image_url) as product_images
        FROM dishes d
        JOIN dish_products dp ON d.id = dp.dish_id
        JOIN products p ON dp.product_id = p.id
        WHERE d.type='肉'
        GROUP BY d.id
        ORDER BY RAND() LIMIT 2`;

    console.log('Executing vegetable query:', vegetableQuery);
    db.query(vegetableQuery, (err, vegetableResult) => {
        if (err) {
            console.error('Error fetching vegetable dish:', err);
            return res.status(500).json({ status: 'error', message: err.message });
        }
        console.log('Vegetable dishes fetched:', vegetableResult);

        console.log('Executing meat query:', meatQuery);
        db.query(meatQuery, (err, meatResult) => {
            if (err) {
                console.error('Error fetching meat dish:', err);
                return res.status(500).json({ status: 'error', message: err.message });
            }
            console.log('Meat dishes fetched:', meatResult);

            const dishSuggestions = {
                vegetables: vegetableResult.map(veg => ({
                    name: veg.dish_name,
                    recipe: veg.recipe,
                    products: veg.product_names.split(','),
                    prices: veg.product_prices.split(',').map(Number),
                    images: veg.product_images.split(',')
                })),
                meats: meatResult.map(meat => ({
                    name: meat.dish_name,
                    recipe: meat.recipe,
                    products: meat.product_names.split(','),
                    prices: meat.product_prices.split(',').map(Number),
                    images: meat.product_images.split(',')
                }))
            };

            console.log('Dish suggestions prepared:', dishSuggestions);
            res.json(dishSuggestions);
        });
    });
});
// 获取所有自取地址
app.get('/pickup-locations', (_req, res) => {
    const query = 'SELECT id AS name, address FROM pickup_locations ORDER BY address ASC';
  
    console.log('接收到獲取自取地點的請求'); // 日誌
  
    db.query(query, (err, results) => {
      if (err) {
        console.error('Error fetching pickup locations:', err); // 錯誤日誌
        res.status(500).send('Internal Server Error');
      } else {
        console.log('獲取的自取地點:', results); // 確認查詢結果
        res.json(results); // 確保返回的是一個數組
      }
    });
  });
  // ----------------------------------------------------------------------------提交訂單-----------------------------------------------------------
  app.post('/api/orders', (req, res) => {
    const { userId, deliveryMethod, paymentMethod, address, pickupLocation, items, totalPrice } = req.body;
  
    if (!userId || !items || items.length === 0) {
      return res.status(400).json({ message: '無效的訂單數據' });
    }
  
    // 插入主訂單
    const orderQuery = `
      INSERT INTO orders (user_id, delivery_method, payment_method, address, pickup_location, total_price)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    db.query(
      orderQuery,
      [userId, deliveryMethod, paymentMethod, address, pickupLocation, totalPrice],
      (err, result) => {
        if (err) {
          console.error('插入訂單失敗:', err);
          return res.status(500).json({ message: '插入訂單失敗' });
        }
  
        const orderId = result.insertId;
  
        
        const orderItemsQuery = `
          INSERT INTO order_items (order_id, product_name, quantity, price)
          VALUES ?
        `;
        const orderItemsData = items.map((item) => [orderId, item.name, item.quantity, item.price]);
  
        db.query(orderItemsQuery, [orderItemsData], (err) => {
          if (err) {
            console.error('插入訂單明細失敗:', err);
            return res.status(500).json({ message: '插入訂單明細失敗' });
          }
  
          
          const updateStockPromises = items.map((item) => {
            const updateStockQuery = `
              UPDATE products
              SET stock = stock - ?
              WHERE name = ? AND stock >= ?; -- 確保庫存足夠
            `;
  
            return new Promise((resolve, reject) => {
              db.query(updateStockQuery, [item.quantity, item.name, item.quantity], (err, result) => {
                if (err) {
                  console.error(`扣減商品 "${item.name}" 庫存失敗:`, err);
                  reject(err);
                } else if (result.affectedRows === 0) {
                  console.error(`商品 "${item.name}" 庫存不足`);
                  reject(new Error(`商品 "${item.name}" 庫存不足`));
                } else {
                  resolve();
                }
              });
            });
          });
  
          // 等待所有庫存扣減操作完成
          Promise.all(updateStockPromises)
            .then(() => {
              res.status(201).json({ message: '訂單提交成功', orderId });
            })
            .catch((err) => {
              console.error('扣減庫存失敗:', err);
              return res.status(500).json({ message: '扣減庫存失敗', error: err.message });
            });
        });
      }
    );
  });
  // ----------------------------------------------------------------------------獲取用戶訂單（包含訂單狀態）-----------------------------------------------------
  app.get('/api/orders/user', (req, res) => {
    const { userId } = req.query; // 從請求參數中獲取 userId
  
    if (!userId) {
      return res.status(400).json({ status: 'error', message: '用戶ID是必要的' });
    }
  
    const ordersQuery = `
      SELECT 
        o.id AS orderId, 
        o.total_price AS totalPrice, 
        o.delivery_method AS deliveryMethod, 
        o.payment_method AS paymentMethod,
        o.address AS address, 
        o.pickup_location AS pickupLocation, 
        o.created_at AS createdAt, 
        o.status AS status,
        oi.product_name AS productName, 
        oi.quantity, 
        oi.price
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.user_id = ?
      ORDER BY o.total_price ASC, o.created_at DESC -- 按 total_price 升序排序，並按時間降序作為次排序
    `;
  
    db.query(ordersQuery, [userId], (err, results) => {
      if (err) {
        console.error('獲取用戶訂單失敗:', err);
        return res.status(500).json({ status: 'error', message: '獲取用戶訂單失敗' });
      }
  
      const orders = {};
      results.forEach((row) => {
        const orderId = row.orderId;
        if (!orders[orderId]) {
          orders[orderId] = {
            orderId,
            totalPrice: row.totalPrice, // 確保 total_price 包含在響應中
            deliveryMethod: row.deliveryMethod,
            paymentMethod: row.paymentMethod,
            address: row.address,
            pickupLocation: row.pickupLocation,
            createdAt: row.createdAt,
            status: row.status,
            items: [],
          };
        }
        orders[orderId].items.push({
          productName: row.productName,
          quantity: row.quantity,
          price: row.price,
        });
      });
  
      res.status(200).json({ status: 'success', orders: Object.values(orders) });
    });
  });