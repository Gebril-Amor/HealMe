# core/models.py
from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    email = models.EmailField(unique=True)
    USER_TYPE_CHOICES = (
        ('patient', 'Patient'),
        ('therapeute', 'Therapeute'),
        ('administrateur', 'Administrateur'),
    )
    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES, default='patient')

class Patient(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True)  # Temporary nullable
    phone = models.CharField(max_length=20, blank=True, null=True)
    dateNaissance = models.DateField(blank=True, null=True)

class Therapeute(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True)  # Temporary nullable
    specialite = models.CharField(max_length=100, blank=True, null=True)
    phone = models.CharField(max_length=20, blank=True, null=True)

class Administrateur(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True)  # Temporary nullable
    departement = models.CharField(max_length=100, blank=True, null=True)
    def __str__(self):
        return f"Administrateur: {self.user.username}"

class Journal(models.Model):
    patient = models.ForeignKey(User, on_delete=models.CASCADE, related_name="journaux")
    date = models.DateField()
    contenu = models.TextField()

class Humeur(models.Model):
    patient = models.ForeignKey(User, on_delete=models.CASCADE, related_name="humeurs")
    date = models.DateField()
    niveau = models.IntegerField()
    description = models.TextField(blank=True)

class Sommeil(models.Model):
    patient = models.ForeignKey(User, on_delete=models.CASCADE, related_name="sommeils")
    date = models.DateField()
    dureeHeures = models.FloatField()
    qualite = models.CharField(max_length=50)

class Session(models.Model):
    date = models.DateField()
    type = models.CharField(max_length=100)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name="sessions")
    therapeute = models.ForeignKey(Therapeute, on_delete=models.CASCADE, related_name="sessions_animees")

class Room(models.Model):
    nom = models.CharField(max_length=100)
    type = models.CharField(max_length=50)
    patients = models.ManyToManyField(Patient, related_name="rooms")

    def __str__(self):
        return self.nom

# core/models.py - Update Message model and add new fields

class Message(models.Model):
    contenu = models.TextField()
    date = models.DateTimeField(auto_now_add=True)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name="messages", null=True)
    therapeute = models.ForeignKey(Therapeute, on_delete=models.CASCADE, related_name="messages", null=True)
    is_read = models.BooleanField(default=False)
    sender_type = models.CharField(
        max_length=10,
        choices=[('patient', 'Patient'), ('therapeute', 'Therapeute')],
        null=True,
        blank=True
    )

    class Meta:
        ordering = ['date']

    def __str__(self):
        return f"Message from {self.sender_type} - {self.date}"
