from rest_framework import serializers
from .models import *

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

class PatientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Patient
        fields = '__all__'

class TherapeuteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Therapeute
        fields = '__all__'

class AdministrateurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Administrateur
        fields = '__all__'

class JournalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Journal
        fields = '__all__'

class HumeurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Humeur
        fields = '__all__'

class SommeilSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sommeil
        fields = '__all__'

class SessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Session
        fields = '__all__'

class RoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Room
        fields = '__all__'

# core/serializers.py
class MessageSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.user.username', read_only=True)
    therapist_name = serializers.CharField(source='therapeute.user.username', read_only=True)
    
    
    class Meta:
        model = Message
        fields = ['id', 'contenu', 'date', 'patient', 'therapeute', 'is_read', 'sender_type', 'patient_name', 'therapist_name']

class TherapistListSerializer(serializers.ModelSerializer):
    user_id = serializers.IntegerField(source='user.id')
    username = serializers.CharField(source='user.username')
    email = serializers.CharField(source='user.email')
    unread_count = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()

    class Meta:
        model = Therapeute
        fields = ['id', 'user_id', 'username', 'email', 'specialite', 'phone', 'unread_count', 'last_message']

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                patient = request.user.patient
                return Message.objects.filter(
                    therapeute=obj,
                    patient=patient,
                    is_read=False,
                    sender_type='therapeute'
                ).count()
            except Patient.DoesNotExist:
                return 0
        return 0

    def get_last_message(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                patient = request.user.patient
                last_message = Message.objects.filter(
                    therapeute=obj,
                    patient=patient
                ).order_by('-date').first()
                if last_message:
                    return {
                        'content': last_message.contenu,
                        'date': last_message.date,
                        'sender_type': last_message.sender_type
                    }
            except Patient.DoesNotExist:
                return None
        return None