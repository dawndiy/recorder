/*
 * Copyright (C) 2016  DawnDIY <dawndiy.dev@gmail.com>
 *
 * This file is part of Recorder
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef AUDIORECORDER_H
#define AUDIORECORDER_H

#include <QObject>
#include <QAudioRecorder>
#include <QAudioProbe>
#include <QStandardPaths>

class AudioRecorder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal microphoneVolume READ microphoneVolume WRITE setMicrophoneVolume NOTIFY microphoneVolumeChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileNameChanged)
    Q_PROPERTY(qint64 recordTime READ recordTime NOTIFY recordTimeChanged)
    Q_PROPERTY(State recordState READ recordState NOTIFY recordStateChanged)
    Q_PROPERTY(QString filePath READ filePath CONSTANT)
    Q_PROPERTY(QString audioCodec READ audioCodec WRITE setAudioCodec NOTIFY audioCodecChanged)
    Q_PROPERTY(QString fileContainer READ fileContainer WRITE setFileContainer NOTIFY fileContainerChanged)
    Q_PROPERTY(int channels READ channels WRITE setChannels NOTIFY channelsChanged)
    Q_PROPERTY(EncodingMode encodingMode READ encodingMode WRITE setEncodingMode NOTIFY encodingModeChanged)
    Q_PROPERTY(EncodingQuality encodingQuality READ encodingQuality WRITE setEncodingQuality NOTIFY encodingQualityChanged)
    Q_PROPERTY(int bitrate READ bitrate WRITE setBitrate NOTIFY bitrateChanged)
    Q_ENUMS(State)
    Q_ENUMS(EncodingMode)
    Q_ENUMS(EncodingQuality)
public:
    explicit AudioRecorder(QObject *parent = 0);
    ~AudioRecorder();

    enum State {
        StoppedState = QAudioRecorder::StoppedState,
        RecordingState = QAudioRecorder::RecordingState,
        PausedState = QAudioRecorder::PausedState
    };
    enum EncodingMode {
        QualityMode = QMultimedia::ConstantQualityEncoding,
        BitrateMode = QMultimedia::ConstantBitRateEncoding
    };
    enum EncodingQuality {
        VeryLowQuality = QMultimedia::VeryLowQuality,
        LowQuality = QMultimedia::LowQuality,
        NormalQuality = QMultimedia::NormalQuality,
        HighQuality = QMultimedia::HighQuality,
        VeryHighQuality = QMultimedia::VeryHighQuality
    };

    qreal microphoneVolume() const;
    QString fileName() const;
    QString filePath() const;
    qint64 recordTime() const;
    State recordState() const;
    QString audioCodec() const;
    QString fileContainer() const;
    int channels() const;
    EncodingMode encodingMode() const;
    EncodingQuality encodingQuality() const;
    int bitrate() const;

    void setMicrophoneVolume(const qreal volume);
    void setAudioCodec(const QString& codec);
    void setFileContainer(const QString& container);
    void setChannels(const int channels);
    void setEncodingMode(const EncodingMode mode);
    void setEncodingQuality(const EncodingQuality quality);
    void setBitrate(const int bitrate);

    Q_INVOKABLE QStringList supportedAudioCodecs();
    Q_INVOKABLE QStringList supportedContainers();

signals:
    void microphoneVolumeChanged(qreal volume);
    void fileNameChanged();
    void recordTimeChanged(qint64 duration);
    void recordStateChanged(State state);
    void error(QString errorMessage);
    void audioCodecChanged();
    void fileContainerChanged();
    void channelsChanged();
    void encodingModeChanged();
    void encodingQualityChanged();
    void bitrateChanged();
    void volumeLevelChanged(qreal level);

public slots:
    void record();
    void pause();
    void resume();
    void stop();
    bool deleteRecordFile(const QString &fileName);
    bool renameRecordFile(const QString &fileName, const QString &newFileName);

private slots:
    void durationChanged(qint64 duration);
    void displayErrorMessage();
    void stateChanged(QMediaRecorder::State state);
    void processBuffer(const QAudioBuffer& buffer);

private:
    qreal m_microphoneVolume;
    qint64 m_recordTime;
    QString m_filePath;
    QString m_fileName;
    State m_state;

    QString m_audioCodec;
    QString m_fileContainer;
    int m_channels;
    EncodingMode m_encodingMode;
    EncodingQuality m_encodingQuality;
    int m_bitrate;

    QAudioRecorder *m_audioRecorder;
    QAudioEncoderSettings m_audioSettings;
    QAudioProbe *m_probe;

private:
    QString newFileName();
    qreal getPeakValue(const QAudioFormat& format);
};

#endif // AUDIORECORDER_H
