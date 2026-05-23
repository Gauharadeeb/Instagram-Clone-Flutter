import os
import django
import urllib.request

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
from posts.models import Post
from django.core.files.uploadedfile import SimpleUploadedFile
from PIL import Image, ImageDraw
import io

User = get_user_model()

def create_gradient_placeholder(unique_id):
    width, height = 800, 600
    palettes = [
        ((32, 44, 57), (122, 161, 178)),
        ((46, 39, 67), (204, 149, 116)),
        ((25, 58, 75), (216, 196, 154)),
        ((56, 74, 64), (185, 212, 176)),
        ((61, 54, 69), (171, 156, 203)),
    ]
    start_color, end_color = palettes[unique_id % len(palettes)]
    img = Image.new('RGB', (width, height), start_color)
    draw = ImageDraw.Draw(img)

    for y in range(height):
        ratio = y / max(height - 1, 1)
        color = tuple(
            int(start_color[channel] * (1 - ratio) + end_color[channel] * ratio)
            for channel in range(3)
        )
        draw.line([(0, y), (width, y)], fill=color)

    return img


def create_placeholder_file(unique_id):
    img = create_gradient_placeholder(unique_id)
    img_io = io.BytesIO()
    img.save(img_io, 'JPEG', quality=90)
    img_io.seek(0)
    return SimpleUploadedFile(
        f'test_image_fallback_{unique_id}.jpg',
        img_io.read(),
        content_type='image/jpeg'
    )


def create_test_image(unique_id):
    image_url = f'https://picsum.photos/800/600?random={unique_id}'

    try:
        request = urllib.request.Request(
            image_url,
            headers={'User-Agent': 'InstagramCloneTestData/1.0'},
        )
        with urllib.request.urlopen(request, timeout=12) as response:
            image_bytes = response.read()

        image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        img_io = io.BytesIO()
        image.save(img_io, 'JPEG', quality=92)
        img_io.seek(0)
        return SimpleUploadedFile(
            f'test_image_{unique_id}.jpg',
            img_io.read(),
            content_type='image/jpeg',
        )
    except Exception as e:
        print(f"Image download failed for {image_url}: {e}. Using gradient fallback.")
        return create_placeholder_file(unique_id)

def create_test_data():
    # Create test users
    users_data = [
        {'username': 'testuser1', 'email': 'test1@example.com', 'password': 'TestPass123!'},
        {'username': 'testuser2', 'email': 'test2@example.com', 'password': 'TestPass123!'},
        {'username': 'testuser3', 'email': 'test3@example.com', 'password': 'TestPass123!'},
    ]
    
    users = []
    for user_data in users_data:
        try:
            user, created = User.objects.get_or_create(
                username=user_data['username'],
                defaults={
                    'email': user_data['email'],
                },
            )
            if created:
                user.set_password(user_data['password'])
                user.save(update_fields=['password'])

            users.append(user)
            action = 'Created' if created else 'Using existing'
            print(f"{action} user: {user.username}")
        except Exception as e:
            print(f"Error creating user {user_data['username']}: {e}")
            # Try to get existing user
            user = User.objects.get(username=user_data['username'])
            users.append(user)
    
    # Create test posts
    captions = [
        'Beautiful sunset today! 🌅',
        'Coffee time ☕',
        'New adventure begins! 🚀',
        'Weekend vibes 🌊',
        'City lights at night 🌃',
    ]
    
    for i, user in enumerate(users):
        for j, caption in enumerate(captions):
            try:
                unique_id = (i + 1) * 100 + (j + 1)
                existing_post = Post.objects.filter(user=user, caption=caption).first()

                if existing_post:
                    existing_post.image = create_test_image(unique_id)
                    existing_post.likes_count = i * 10 + j * 5
                    existing_post.save(update_fields=['image', 'likes_count', 'updated_at'])
                    print(f"Updated post {j+1} image for user {user.username}")
                    continue

                post = Post.objects.create(
                    user=user,
                    image=create_test_image(unique_id),
                    caption=caption,
                    likes_count=i * 10 + j * 5
                )
                print(f"Created post {j+1} for user {user.username}")
            except Exception as e:
                print(f"Error creating post: {e}")
    
    print(f"\nTotal posts created: {Post.objects.count()}")
    print(f"Total users: {User.objects.count()}")

if __name__ == '__main__':
    create_test_data()
