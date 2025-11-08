from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import *
from . import views

router = DefaultRouter()
router.register(r'patients', PatientViewSet)
router.register(r'journaux', JournalViewSet)
router.register(r'humeurs', HumeurViewSet)
router.register(r'sommeils', SommeilViewSet)
router.register(r'sessions', SessionViewSet)
router.register(r'rooms', RoomViewSet)
router.register(r'messages', MessageViewSet)
router.register(r'therapists', TherapistViewSet)



urlpatterns = [
    path('users/<int:user_id>/mood/', views.get_user_mood, name='user-mood-all'),
    path('users/<int:user_id>/sleep/', views.get_user_sleep, name='user-sleep-all'),
    path('users/<int:user_id>/journal/', views.get_user_journal, name='user-journal-all'),
    path('register/', views.register, name='register'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('check-auth/', views.check_auth, name='check_auth'),
    path('conversation/<int:patient_id>/<int:therapist_id>/', get_conversation_messages),
    path('send-message/', send_message),
    path('api/therapist/<int:therapist_id>/conversations/', views.therapist_conversations, name='therapist_conversations'),
    path('all-patients/', views.all_patients, name='all_patients'),
    path('', include(router.urls)),
]
