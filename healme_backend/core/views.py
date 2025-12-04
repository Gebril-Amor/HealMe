# core/views.py - Fixed with only one send_message function
from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth import authenticate, login, logout
from .models import *
from .serializers import *
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .models import User, Humeur, Sommeil, Journal, Patient
from .serializers import HumeurSerializer, SommeilSerializer, JournalSerializer
from rest_framework.decorators import *
from django.http import JsonResponse
from django.views import View
from google import genai
from dotenv import load_dotenv
import os

load_dotenv()  # loads the .env file

@api_view(['GET'])
def get_user_mood(request, user_id):
    """Get ALL mood data for a user by user ID"""
    try:
        user = get_object_or_404(User, id=user_id)
        
        # Now filter directly by User (since models use User ForeignKey)
        humeurs = Humeur.objects.filter(patient=user).order_by('-date')
        serializer = HumeurSerializer(humeurs, many=True)
        
        return Response(serializer.data)
        
    except Exception as e:
        print(f"Error in get_user_mood: {str(e)}")
        return Response(
            {"error": "Internal server error"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['GET'])
def get_user_sleep(request, user_id):
    """Get ALL sleep data for a user by user ID"""
    try:
        user = get_object_or_404(User, id=user_id)
        
        # Filter directly by User
        sommeils = Sommeil.objects.filter(patient=user).order_by('-date')
        serializer = SommeilSerializer(sommeils, many=True)
        
        return Response(serializer.data)
        
    except Exception as e:
        print(f"Error in get_user_sleep: {str(e)}")
        return Response(
            {"error": "Internal server error"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['GET'])
def get_user_journal(request, user_id):
    """Get ALL journal data for a user by user ID"""
    try:
        user = get_object_or_404(User, id=user_id)
        
        # Filter directly by User
        journaux = Journal.objects.filter(patient=user).order_by('-date')
        serializer = JournalSerializer(journaux, many=True)
        
        return Response(serializer.data)
        
    except Exception as e:
        print(f"Error in get_user_journal: {str(e)}")
        return Response(
            {"error": "Internal server error"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

# ===== AUTHENTICATION VIEWS =====
@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    try:
        data = request.data
        
        # Validate required fields
        required_fields = ['username', 'email', 'password']
        for field in required_fields:
            if field not in data:
                return Response({'error': f'{field} is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if user already exists
        if User.objects.filter(username=data['username']).exists():
            return Response({'error': 'Username already exists'}, status=status.HTTP_400_BAD_REQUEST)
        
        if User.objects.filter(email=data['email']).exists():
            return Response({'error': 'Email already exists'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Create user
        user = User.objects.create_user(
            username=data['username'],
            email=data['email'],
            password=data['password']
        )
        user.user_type = data['user_type']
        user.save()
        # Create specific profile based on user_type
        user_type = data['user_type']
        profile_data = {}
        
        if user_type == 'patient':
            profile = Patient.objects.create(user=user, **data.get('profile_data', {}))
            profile_data = PatientSerializer(profile).data
        elif user_type == 'therapeute':
            profile = Therapeute.objects.create(user=user, **data.get('profile_data', {}))
            profile_data = TherapeuteSerializer(profile).data
        elif user_type == 'administrateur':
            profile = Administrateur.objects.create(user=user, **data.get('profile_data', {}))
            profile_data = AdministrateurSerializer(profile).data
        else:
            user.delete()
            return Response({'error': 'Invalid user type'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Auto-login after registration
        login(request, user)
        
        return Response({
            'message': 'Registration successful',
            'user': UserSerializer(user).data,
            'profile': profile_data
        }, status=status.HTTP_201_CREATED)
            
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    try:
        data = request.data
        print(f"Login attempt with: {data}")  # Debug
        
        # Validate required fields
        if 'email' not in data or 'password' not in data:
            return Response({'error': 'Email and password are required'}, status=status.HTTP_400_BAD_REQUEST)
        
        # First, find the user by email
        try:
            user_by_email = User.objects.get(email=data['email'])
            print(f"Found user by email: {user_by_email.username}")  # Debug
        except User.DoesNotExist:
            print("No user found with this email")  # Debug
            return Response({'error': 'Invalid email or password'}, status=status.HTTP_401_UNAUTHORIZED)
        
        # Now authenticate using the actual username (not email)
        user = authenticate(username=user_by_email.username, password=data['password'])
        print(f"Authentication result: {user}")  # Debug
        
        if user is not None:
            login(request, user)
            print(f"Login successful for: {user.username}")  # Debug
            
            # Get user profile based on user type
            profile_data = None
            if hasattr(user, 'patient'):
                profile_data = PatientSerializer(user.patient).data
            elif hasattr(user, 'therapeute'):
                profile_data = TherapeuteSerializer(user.therapeute).data
            elif hasattr(user, 'administrateur'):
                profile_data = AdministrateurSerializer(user.administrateur).data
            
            return Response({
                'message': 'Login successful',
                'user': UserSerializer(user).data,
                'profile': profile_data
            }, status=status.HTTP_200_OK)
        else:
            print("Authentication failed - wrong password")  # Debug
            return Response({'error': 'Invalid email or password'}, status=status.HTTP_401_UNAUTHORIZED)
            
    except Exception as e:
        print(f"Login error: {str(e)}")  # Debug
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
def logout_view(request):
    try:
        logout(request)
        return Response({'message': 'Successfully logged out'}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def check_auth(request):
    """Check if user is authenticated"""
    if request.user.is_authenticated:
        profile_data = None
        if hasattr(request.user, 'patient'):
            profile_data = PatientSerializer(request.user.patient).data
        elif hasattr(request.user, 'therapeute'):
            profile_data = TherapeuteSerializer(request.user.therapeute).data
        elif hasattr(request.user, 'administrateur'):
            profile_data = AdministrateurSerializer(request.user.administrateur).data
            
        return Response({
            'authenticated': True,
            'user': UserSerializer(request.user).data,
            'profile': profile_data
        })
    else:
        return Response({'authenticated': False})

class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer

class JournalViewSet(viewsets.ModelViewSet):
    queryset = Journal.objects.all()
    serializer_class = JournalSerializer

class HumeurViewSet(viewsets.ModelViewSet):
    queryset = Humeur.objects.all()
    serializer_class = HumeurSerializer

class SommeilViewSet(viewsets.ModelViewSet):
    queryset = Sommeil.objects.all()
    serializer_class = SommeilSerializer

class SessionViewSet(viewsets.ModelViewSet):
    queryset = Session.objects.all()
    serializer_class = SessionSerializer

class RoomViewSet(viewsets.ModelViewSet):
    queryset = Room.objects.all()
    serializer_class = RoomSerializer

# core/views.py - Temporary fix for testing
class TherapistViewSet(viewsets.ModelViewSet):
    queryset = Therapeute.objects.all()
    serializer_class = TherapistListSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def list(self, request):
        # TEMPORARY: Allow access without authentication for testing
        # Remove this in production
        therapists = self.get_queryset()
        serializer = self.get_serializer(therapists, many=True)
        return Response(serializer.data)

# core/views.py - Update MessageViewSet
class MessageViewSet(viewsets.ModelViewSet):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer
    permission_classes = [AllowAny]  # Add this for testing

    def get_queryset(self):
        # Simplified - just return all messages for the therapist
        therapist_id = self.request.query_params.get('therapist_id')
        if therapist_id:
            return Message.objects.filter(therapeute_id=therapist_id).order_by('date')
        return Message.objects.all().order_by('date')

    def perform_create(self, serializer):
        # Simplified for testing - always create as patient message
        therapist_id = self.request.data.get('therapeute')
        serializer.save(
            patient_id=1,  # Default patient ID for testing
            therapeute_id=therapist_id,
            sender_type='patient'
        )

# core/views.py - Remove auth verification from get_conversation_messages
@api_view(['GET'])
@permission_classes([AllowAny])  # Add this to allow any access
def get_conversation_messages(request, patient_id, therapist_id):
    """
    Get messages between specific patient and therapist
    No authentication required for testing
    """
    try:
        # REMOVED AUTH VERIFICATION - allow any access
        # Get messages between this patient and therapist
        messages = Message.objects.filter(
            patient_id=patient_id,
            therapeute_id=therapist_id
        ).order_by('date')
        
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)
        
    except Exception as e:
        return Response({'error': str(e)}, status=400)


@api_view(['POST'])
@permission_classes([AllowAny])
def send_message(request):
    """
    Send a message between patient and therapist
    Use actual patient_id from request and respect sender_type
    """
    try:
        data = request.data
        
        # Get all required fields from request data
        patient_id = data.get('patient_id')
        therapist_id = data.get('therapist_id')
        contenu = data.get('contenu')
        sender_type = data.get('sender_type', 'patient')  # Get sender_type, default to 'patient'
        
        # Validate required fields
        if not all([patient_id, therapist_id, contenu]):
            return Response(
                {'error': 'patient_id, therapist_id, and contenu are required'}, 
                status=400
            )
        
        # Validate sender_type
        if sender_type not in ['patient', 'therapeute']:
            return Response(
                {'error': 'sender_type must be either "patient" or "therapeute"'}, 
                status=400
            )
        
        # Create message with actual IDs and correct sender_type
        message = Message.objects.create(
            patient_id=patient_id,
            therapeute_id=therapist_id,
            contenu=contenu,
            sender_type=sender_type  # Use the provided sender_type
        )
        
        serializer = MessageSerializer(message)
        return Response(serializer.data, status=201)
        
    except Exception as e:
        return Response({'error': str(e)}, status=400)
    
    
@api_view(['GET'])
@permission_classes([AllowAny])
def therapist_conversations(request, therapist_id):


    """
    Get all conversations for a therapist (only patients who actually messaged)
    """
    try:
        # Get unique patients who have conversations with this therapist
        conversations = Message.objects.filter(
            therapeute_id=therapist_id
        ).select_related(
            'patient__user'
        ).order_by('-date')
        
        # Group by patient and get latest message
        conversation_map = {}
        for message in conversations:
            patient_id = message.patient_id
            if patient_id not in conversation_map:
                conversation_map[patient_id] = {
                    'patient_id': patient_id,
                    'patient_name': message.patient.user.username,
                    'patient_email': message.patient.user.email,
                    'last_message': {
                        'content': message.contenu,
                        'date': message.date,
                        'sender_type': message.sender_type
                    },
                    'unread_count': 0  # We'll calculate this separately
                }
        
        # Calculate unread counts for each conversation
        for patient_id in conversation_map.keys():
            unread_count = Message.objects.filter(
                therapeute_id=therapist_id,
                patient_id=patient_id,
                sender_type='patient',
                is_read=False
            ).count()
            conversation_map[patient_id]['unread_count'] = unread_count
        
        conversation_list = list(conversation_map.values())
        
        # Sort by last message date (newest first)
        conversation_list.sort(key=lambda x: x['last_message']['date'], reverse=True)
        
        return Response(conversation_list)
        
    except Exception as e:
        return Response({'error': str(e)}, status=400)


# core/views.py - Add this simple view
@api_view(['GET'])
@permission_classes([AllowAny])
def all_patients(request):
    """
    Get ALL patients for therapist to see
    """
    try:
        patients = Patient.objects.select_related('user').all()
        
        patient_list = []
        for patient in patients:
            patient_list.append({
                'patient_id': patient.id,
                'patient_name': patient.user.username,
                'patient_email': patient.user.email,
            })
        
        return Response(patient_list)
        
    except Exception as e:
        return Response({'error': str(e)}, status=400)
    

# --- Initialization ---
# Get API Key securely from environment variables
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
# Initialize the client (make sure GEMINI_API_KEY is set in your .env)
client = genai.Client(api_key=GEMINI_API_KEY) 
model_name = 'gemini-2.5-flash'

class GeminiTestView(View):
    """
    A simple Django view to test the connection to the Gemini API.
    Access this route in your browser to see the result.
    """
    def get(self, request, *args, **kwargs):
        # 1. Define the test prompt
        test_prompt = "Explain the concept of Django REST Framework in one concise sentence."
        
        try:
            # 2. Call the Gemini API
            print(f"Sending prompt to Gemini: '{test_prompt}'")
            response = client.models.generate_content(
                model=model_name,
                contents=test_prompt
            )
            
            # 3. Format the result for JSON response
            ai_response_text = response.text
            
            return JsonResponse({
                'status': 'success',
                'prompt_sent': test_prompt,
                'model_used': model_name,
                'ai_response': ai_response_text
            }, status=200)

        except Exception as e:
            # 4. Handle errors (e.g., key not set, API connection failed)
            print(f"Error calling Gemini API: {e}")
            return JsonResponse({
                'status': 'error',
                'message': 'Failed to connect to or get a response from the Gemini API.',
                'detail': str(e)
            }, status=500)

@api_view(['GET'])
@permission_classes([AllowAny])
def get_user_mood_insight(request, user_id):
    """
    Get moods for a user + AI insight (Gemini)
    """
    try:
        user = get_object_or_404(User, id=user_id)
        moods = Humeur.objects.filter(patient=user).order_by('-date')
        serializer = HumeurSerializer(moods, many=True)

        if not moods.exists():
            return Response({
                "moods": [],
                "ai_insight": "No mood data to analyze."
            }, status=200)

        mood_text = "\n".join([f"{m.date}: Niveau {m.niveau} - {m.description if m.description else 'Aucune note'}" for m in moods if m.description])

        ai_prompt = f"""
Please generate a one phrases that suggests activities or advice (an activity that patient can do to imporve health) based on the following mood data:

{mood_text}
"""

        response = client.models.generate_content(
            model=model_name,
            contents=ai_prompt
        )

        ai_result = response.text

        return Response({
            "ai_insight": ai_result
        }, status=200)

    except Exception as e:
        return Response({"error": str(e)}, status=500)
    
@api_view(['GET'])
@permission_classes([AllowAny])
def get_user_sleep_insight(request, user_id):
    """
    Get sleep data for a user + AI insight (Gemini)
    """
    try:
        user = get_object_or_404(User, id=user_id)
        sleeps = Sommeil.objects.filter(patient=user).order_by('-date')
        serializer = SommeilSerializer(sleeps, many=True)

        if not sleeps.exists():
            return Response({
                "sleep": [],
                "ai_insight": "No sleep data to analyze."
            }, status=200)

        # Format sleep data for AI
        sleep_text = "\n".join([
            f"{s.date}: {s.dureeHeures} hours, quality = {s.qualite}"
            for s in sleeps
        ])

        ai_prompt = f"""
Please generate one single phrase of sleep advice based on this person's sleep patterns.
Make the suggestion practical and short.

Sleep data:

{sleep_text}
"""

        response = client.models.generate_content(
            model=model_name,
            contents=ai_prompt
        )

        ai_result = response.text

        return Response({
            "ai_insight": ai_result
        }, status=200)

    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['GET'])
@permission_classes([AllowAny])
def get_user_journal_insight(request, user_id):
    """
    Get journal entries for a user + AI insight (Gemini)
    """
    try:
        user = get_object_or_404(User, id=user_id)
        journals = Journal.objects.filter(patient=user).order_by('-date')
        serializer = JournalSerializer(journals, many=True)

        if not journals.exists():
            return Response({
                "journal": [],
                "ai_insight": "No journal entries to analyze."
            }, status=200)

        # Format journal text for AI
        journal_text = "\n".join([
            f"{j.date}: {j.contenu[:200]}..."
            for j in journals
        ])

        ai_prompt = f"""
Please summarize the emotional tone of this person's journal entries in one short sentence.
Avoid deep analysis, keep it supportive and simple.

Journal entries:

{journal_text}
"""

        response = client.models.generate_content(
            model=model_name,
            contents=ai_prompt
        )

        ai_result = response.text

        return Response({
            "ai_insight": ai_result
        }, status=200)

    except Exception as e:
        return Response({"error": str(e)}, status=500)
    

@api_view(['POST'])
@permission_classes([AllowAny])
def ai_chat_reply(request):
    """
    Generate an AI response to a user's chat message (Gemini).
    """
    try:
        user_message = request.data.get("message", "")

        if not user_message or user_message.strip() == "":
            return Response(
                {"error": "Message field cannot be empty."},
                status=400
            )

        ai_prompt = f"""
You are a supportive assistant. Respond in a short, warm, simple tone.

User said:
{user_message}
"""

        response = client.models.generate_content(
            model=model_name,
            contents=ai_prompt
        )

        ai_reply = response.text

        return Response({
            "reply": ai_reply
        }, status=200)

    except Exception as e:
        return Response({"error": str(e)}, status=500)
