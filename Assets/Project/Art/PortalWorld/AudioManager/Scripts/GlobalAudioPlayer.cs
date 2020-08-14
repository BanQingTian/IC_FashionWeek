using UnityEngine;

public static class GlobalAudioPlayer
{

    public static BeatEmUpTemplate.AudioPlayer audioPlayer;

    public static void PlaySFX(string sfxName)
    {
        if (audioPlayer != null && sfxName != "") audioPlayer.playSFX(sfxName);
    }

    public static void PlaySFXAtPosition(string sfxName, Vector3 position)
    {
        if (audioPlayer != null && sfxName != "") audioPlayer.playSFXAtPosition(sfxName, position);
    }

    public static void PlaySFXAtPosition(string sfxName, Vector3 position, Transform parent)
    {
        if (audioPlayer != null && sfxName != "") audioPlayer.playSFXAtPosition(sfxName, position, parent);
    }

    public static GameObject PlayMusic(string musicName)
    {
        if (audioPlayer != null) return audioPlayer.playMusic(musicName);
        return null;
    }
}