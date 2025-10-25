from flask import Flask, render_template, request, jsonify
from db_manager import execute_procedure, execute_query
import os

app = Flask(__name__, template_folder='templates') 

# =================================================================
# PAGE ROUTES (Serve HTML)
# =================================================================

@app.route('/')
def index():
    """Main dashboard"""
    return render_template('index.html')

@app.route('/renew')
def renew_page():
    """Subscription renewal page"""
    return render_template('renew.html')

@app.route('/content')
def content_page():
    """Content viewing and rating page"""
    return render_template('content.html')

@app.route('/watchlist')
def watchlist_page():
    """Watchlist management page"""
    return render_template('watchlist.html')

@app.route('/recommendations')
def recommendations_page():
    """Recommendations page"""
    return render_template('recommendations.html')

@app.route('/search')
def search_page():
    """Search content page"""
    return render_template('search.html')

@app.route('/users')
def users_page():
    """User management page"""
    return render_template('users.html')

@app.route('/analytics')
def analytics_page():
    """Analytics dashboard"""
    return render_template('analytics.html')

# =================================================================
# API ROUTES
# =================================================================

# 1. Subscription Management
@app.route('/api/subscription/renew', methods=['POST'])
def api_renew_sub():
    data = request.json
    user_id = data.get('user_id')
    payment_method = data.get('payment_method')
    
    if not user_id or not payment_method:
        return jsonify({'status': 'error', 'message': 'Missing user ID or payment method.'}), 400
        
    result = execute_procedure('sp_renew_subscription', (user_id, payment_method))
    
    if result.get('status') == 'error':
        return jsonify(result), 500
        
    return jsonify({'status': 'success', 'message': f'Subscription renewed for User {user_id}'})

@app.route('/api/subscription/info/<int:user_id>', methods=['GET'])
def api_subscription_info(user_id):
    results = execute_procedure('sp_get_user_subscription', (user_id,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

# 2. User Watch History
@app.route('/api/user/summary/<int:user_id>', methods=['GET'])
def api_user_summary(user_id):
    results = execute_procedure('sp_user_watch_summary', (user_id,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

@app.route('/api/user/watch-progress', methods=['POST'])
def api_record_watch():
    data = request.json
    profile_id = data.get('profile_id')
    content_id = data.get('content_id')
    progress = data.get('progress')
    
    if not all([profile_id, content_id, progress is not None]):
        return jsonify({'status': 'error', 'message': 'Missing required fields'}), 400
    
    result = execute_procedure('sp_record_watch_progress', (profile_id, content_id, progress))
    
    if isinstance(result, dict) and result.get('status') == 'error':
        return jsonify(result), 500
        
    return jsonify({'status': 'success', 'message': 'Watch progress recorded'})

# 3. Content Management
@app.route('/api/content/all', methods=['GET'])
def api_get_content():
    query = """
        SELECT Content_Id, Title, Type, Release_Year, Language, 
               Content_Rating, Total_Views 
        FROM content 
        ORDER BY Content_Rating DESC, Total_Views DESC 
        LIMIT 50
    """
    results = execute_query(query)

    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

@app.route('/api/content/details/<int:content_id>', methods=['GET'])
def api_content_details(content_id):
    results = execute_procedure('sp_get_content_details', (content_id,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

@app.route('/api/content/top-rated', methods=['GET'])
def api_top_rated():
    limit = request.args.get('limit', 10, type=int)
    results = execute_procedure('sp_get_top_rated_content', (limit,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

@app.route('/api/content/popular', methods=['GET'])
def api_popular():
    limit = request.args.get('limit', 10, type=int)
    results = execute_procedure('sp_get_popular_content', (limit,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

@app.route('/api/content/by-genre/<genre>', methods=['GET'])
def api_content_by_genre(genre):
    results = execute_procedure('sp_get_content_by_genre', (genre,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

@app.route('/api/content/search', methods=['GET'])
def api_search_content():
    search_term = request.args.get('q', '')
    
    if not search_term:
        return jsonify({'status': 'error', 'message': 'Search term required'}), 400
    
    results = execute_procedure('sp_search_content', (search_term,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

# 4. Ratings
@app.route('/api/content/rate', methods=['POST'])
def api_add_rating():
    data = request.json
    profile_id = data.get('profile_id')
    content_id = data.get('content_id')
    rating = data.get('rating')
    review = data.get('review', '')

    if not all([profile_id, content_id, rating]):
        return jsonify({'status': 'error', 'message': 'Missing rating data.'}), 400

    # Get max rating ID
    max_query = "SELECT COALESCE(MAX(Ratings_Id), 0) + 1 AS next_id FROM ratings"
    max_result = execute_query(max_query)
    next_id = max_result[0]['next_id'] if max_result else 1

    query = """
        INSERT INTO ratings (Ratings_Id, Profile_Id, Content_Id, Rating, Review_Text) 
        VALUES (%s, %s, %s, %s, %s)
    """
    result = execute_query(query, (next_id, profile_id, content_id, rating, review))
    
    if result and result.get('status') == 'error':
        return jsonify(result), 500
        
    return jsonify({'status': 'success', 'message': 'Rating added successfully'})

# 5. Watchlist Management
@app.route('/api/watchlist/<int:profile_id>', methods=['GET'])
def api_get_watchlist(profile_id):
    results = execute_procedure('sp_get_profile_watchlist', (profile_id,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

@app.route('/api/watchlist/add', methods=['POST'])
def api_add_to_watchlist():
    data = request.json
    profile_id = data.get('profile_id')
    content_id = data.get('content_id')
    
    if not all([profile_id, content_id]):
        return jsonify({'status': 'error', 'message': 'Missing required fields'}), 400
    
    result = execute_procedure('sp_add_to_watchlist', (profile_id, content_id))
    
    if isinstance(result, dict) and result.get('status') == 'error':
        return jsonify(result), 500
        
    return jsonify({'status': 'success', 'message': 'Added to watchlist'})

@app.route('/api/watchlist/remove/<int:watchlist_id>', methods=['DELETE'])
def api_remove_from_watchlist(watchlist_id):
    result = execute_procedure('sp_remove_from_watchlist', (watchlist_id,))
    
    if isinstance(result, dict) and result.get('status') == 'error':
        return jsonify(result), 500
        
    return jsonify({'status': 'success', 'message': 'Removed from watchlist'})

# 6. Recommendations
@app.route('/api/recommendations/<int:user_id>', methods=['GET'])
def api_recommendations(user_id):
    results = execute_procedure('sp_get_user_recommendations', (user_id,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

# 7. User Management
@app.route('/api/users/all', methods=['GET'])
def api_all_users():
    results = execute_procedure('sp_get_all_users_status', ())
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

# 8. Actor Information
@app.route('/api/actor/<int:actor_id>', methods=['GET'])
def api_actor_filmography(actor_id):
    results = execute_procedure('sp_get_actor_filmography', (actor_id,))
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

# 9. Genres
@app.route('/api/genres', methods=['GET'])
def api_get_genres():
    query = "SELECT Genre_Id, Name FROM genre ORDER BY Name"
    results = execute_query(query)
    
    if isinstance(results, dict) and results.get('status') == 'error':
        return jsonify(results), 500
        
    return jsonify(results)

if __name__ == '__main__':
    print(f"Current Working Directory: {os.getcwd()}")
    print("Starting Flask server on http://127.0.0.1:5000")
    app.run(debug=True, port=5000)
