-- Create the database
CREATE DATABASE programa_tu_paladar;

-- Connect to the newly created database
-- \c programa_tu_paladar

-- Create a role with login
CREATE ROLE db_admin WITH LOGIN PASSWORD 'cH@ng3M3n0W!';

-- Grant all privileges on the database to the new role
GRANT ALL PRIVILEGES ON DATABASE programa_tu_paladar TO db_admin;

-- Create user accounts table
CREATE TABLE user_accounts (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hashed_password CHAR(60) NOT NULL, -- Assuming bcrypt hash which generates a 60-character string
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    profile_picture_url VARCHAR(255),
    bio TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMPTZ
);

-- Create indexes for columns that will be searched often
CREATE INDEX idx_user_accounts_username ON user_accounts(username);
CREATE INDEX idx_user_accounts_email ON user_accounts(email);

-- Insert dummy users
-- Note: The 'hashed_password' values should be actual hashes of passwords
INSERT INTO user_accounts (username, email, hashed_password, profile_picture_url, bio, is_active)
VALUES
    ('john_doe', 'john.doe@example.com', 'hashedpassword123', 'https://loremflickr.com/200/200/food', 'Food enthusiast and amateur chef.', TRUE),
    ('jane_smith', 'jane.smith@example.com', 'hashedpassword456', 'https://loremflickr.com/200/200/food', 'Baker and recipe creator.', TRUE),
    ('cooking_ninja', 'cooking.ninja@example.com', 'hashedpassword202', 'https://loremflickr.com/200/200/food', 'Exploring the world through its cuisines.', TRUE);

-- Create the recipes table
CREATE TABLE recipes (
    recipe_id SERIAL PRIMARY KEY,
    author_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    ingredients TEXT NOT NULL,
    instructions TEXT NOT NULL,
    prep_time INT,
    cook_time INT,
    total_time INT GENERATED ALWAYS AS (prep_time + cook_time) STORED,
    servings INT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    image_url VARCHAR(255),
    CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES user_accounts(user_id) ON DELETE CASCADE
);

-- Create indexes for columns that will be searched or filtered often
CREATE INDEX idx_recipes_title ON recipes(title);

-- Insert dummy recipes
-- Note: Ensure that 'author_id' matches valid 'user_id' from the 'user_accounts' table
INSERT INTO recipes (author_id, title, description, ingredients, instructions, prep_time, cook_time, servings, image_url)
VALUES
    (1, 'Classic Tomato Spaghetti', 'A simple and classic spaghetti recipe using fresh tomatoes.', 'Spaghetti, tomatoes, olive oil, garlic, basil', 'Boil spaghetti, sauté tomatoes with garlic, mix and serve.', 10, 20, 2, 'https://example.com/images/tomato-spaghetti.jpg'),
    (2, 'Hearty Vegetable Soup', 'A nutritious and warming vegetable soup perfect for cold days.', 'Carrots, potatoes, onions, celery, vegetable stock', 'Chop vegetables, simmer in stock until tender.', 15, 30, 4, 'https://example.com/images/vegetable-soup.jpg'),
    (3, 'Lemon Drizzle Cake', 'A moist and tangy lemon drizzle cake that melts in your mouth.', 'Flour, sugar, eggs, lemon, baking powder', 'Mix ingredients, bake, and drizzle with lemon syrup.', 20, 45, 8, 'https://example.com/images/lemon-cake.jpg');

-- Continue with the creation of tables for categories, tags, ratings, friendships, and comments
-- The structure of these tables will be similar to the one provided in the original script, with necessary modifications for PostgreSQL

-- Create the categories table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Insert categories
INSERT INTO categories (name, description)
VALUES 
    ('Appetizers', 'Start your meal with these delicious appetizers'),
    ('Main Courses', 'Hearty and fulfilling main course dishes'),
    ('Vegetarian', 'Plant-based recipes for vegetarians'),
    ('Vegan', 'Dairy-free and meat-free recipes for vegans'),
    ('Gluten-Free', 'Recipes without gluten for those with allergies or preferences'),
    ('Breakfast', 'Start your day with these breakfast ideas'),
    ('Lunch', 'Midday meals to keep you going'),
    ('Dinner', 'Evening meals to enjoy with family and friends'),
    ('Snacks', 'Quick bites for in-between meals'),
    ('Drinks', 'Beverages to accompany your meals or to enjoy on their own'),
    ('Desserts', 'Sweet treats to finish off your meal');

-- Create the recipe_categories linking table
CREATE TABLE recipe_categories (
    recipe_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (recipe_id, category_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Continue inserting relationships between recipes and categories
INSERT INTO recipe_categories (recipe_id, category_id)
VALUES
    (1, (SELECT category_id FROM categories WHERE name = 'Main Courses')),
    (2, (SELECT category_id FROM categories WHERE name = 'Dinner')),
    (3, (SELECT category_id FROM categories WHERE name = 'Desserts'));

-- Create the tags table
CREATE TABLE tags (
    tag_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT
);

INSERT INTO tags (name, description)
VALUES 
    ('Vegetarian', 'Excludes meat and fish, may include dairy and eggs'),
    ('Vegan', 'Excludes all animal products'),
    ('Gluten-Free', 'Free from gluten-containing grains'),
    ('Dairy-Free', 'Excludes dairy products'),
    ('Low-Sodium', 'Low in salt content'),
    ('Breakfast', 'Recipes suitable for the first meal of the day'),
    ('Brunch', 'Combination of breakfast and lunch dishes'),
    ('Lunch', 'Midday meal recipes'),
    ('Dinner', 'Main meal of the evening'),
    ('Snack', 'Light meals or bites between main meals'),
    ('Dessert', 'Sweet course that concludes a meal'),
    ('Main Course', 'Central or primary dish of a meal'),
    ('Salad', 'Dish consisting of mixed pieces of food'),
    ('Soup', 'Liquid dish, typically savory and warm'),
    ('Freezer-Friendly', 'Recipes suitable for freezing and reheating');

-- Create the recipe_tags linking table
CREATE TABLE recipe_tags (
    recipe_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (recipe_id, tag_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- Continue inserting relationships between recipes and tags
INSERT INTO recipe_tags (recipe_id, tag_id)
VALUES
    (1, (SELECT tag_id FROM tags WHERE name = 'Dinner')),
    (2, (SELECT tag_id FROM tags WHERE name = 'Vegetarian')),
    (3, (SELECT tag_id FROM tags WHERE name = 'Dessert'));

-- Create the ratings table
CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY,
    recipe_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5), -- Assuming a 1-5 rating scale
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id) ON DELETE CASCADE,
    UNIQUE (recipe_id, user_id) -- Each user can rate a recipe only once
);

-- Create the user_friends table
CREATE TABLE user_friends (
    friendship_id SERIAL PRIMARY KEY,
    user_id1 INT NOT NULL,
    user_id2 INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id1) REFERENCES user_accounts(user_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id2) REFERENCES user_accounts(user_id) ON DELETE CASCADE,
    CHECK (user_id1 <> user_id2),
    UNIQUE (user_id1, user_id2)
);

-- Create the user_comments table
CREATE TABLE user_comments (
    comment_id SERIAL PRIMARY KEY,
    recipe_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id) ON DELETE CASCADE
);
