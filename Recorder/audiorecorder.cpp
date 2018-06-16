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

#include <QDateTime>
#include <QDir>
#include <QUrl>
#include "audiorecorder.h"

static QVector<qreal> getBufferLevels(const QAudioBuffer &buffer);

template <class T>
static QVector<qreal> getBufferLevels(const T *buffer, int frames, int channels);

//-----------------------------------------------------------------------------
// Constructor and destructor
//-----------------------------------------------------------------------------

AudioRecorder::AudioRecorder(QObject *parent) : QObject(parent)
{
    m_state = StoppedState;
    m_recordTime = 0;
    m_fileName = "";
    m_microphoneVolume = 90;

    // Init fill path to store record files
    m_filePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    m_filePath += "/records";
    QDir dir(m_filePath);
    if (!dir.exists()) {
        dir.mkpath(m_filePath);
    }

    // default audio settings
    m_audioCodec = "audio/x-vorbis";
    m_fileContainer = "audio/ogg";
    m_channels = 2;
    m_encodingMode = QualityMode;
    m_encodingQuality = NormalQuality;
    m_bitrate = 128000;

    m_audioRecorder = new QAudioRecorder(this);
    m_probe = new QAudioProbe;

    connect(m_probe, SIGNAL(audioBufferProbed(QAudioBuffer)),
            this, SLOT(processBuffer(QAudioBuffer)));
    m_probe->setSource(m_audioRecorder);

    connect(m_audioRecorder, SIGNAL(durationChanged(qint64)),
            this, SLOT(durationChanged(qint64)));
    connect(m_audioRecorder, SIGNAL(error(QMediaRecorder::Error)),
            this, SLOT(displayErrorMessage()));
    connect(m_audioRecorder, SIGNAL(stateChanged(QMediaRecorder::State)),
            this, SLOT(stateChanged(QMediaRecorder::State)));
}

AudioRecorder::~AudioRecorder()
{
    delete m_audioRecorder;
    delete m_probe;
}

//-----------------------------------------------------------------------------
// Public methods
//-----------------------------------------------------------------------------

qreal AudioRecorder::microphoneVolume() const
{
    return m_microphoneVolume;
}

QString AudioRecorder::fileName() const
{
    return m_fileName;
}

QString AudioRecorder::filePath() const
{
    return m_filePath;
}

qint64 AudioRecorder::recordTime() const
{
    return m_recordTime;
}

AudioRecorder::State AudioRecorder::recordState() const
{
    return m_state;
}

QString AudioRecorder::audioCodec() const
{
    return m_audioCodec;
}

QString AudioRecorder::fileContainer() const
{
    return m_fileContainer;
}

int AudioRecorder::channels() const
{
    return m_channels;
}

AudioRecorder::EncodingMode AudioRecorder::encodingMode() const
{
    return m_encodingMode;
}

AudioRecorder::EncodingQuality AudioRecorder::encodingQuality() const
{
    return m_encodingQuality;
}

int AudioRecorder::bitrate() const
{
    return m_bitrate;
}

void AudioRecorder::setMicrophoneVolume(const qreal volume)
{
    if (volume != m_microphoneVolume) {
        m_microphoneVolume = volume;
        m_audioRecorder->setVolume(m_microphoneVolume / 100.0);
        emit microphoneVolumeChanged(volume);
    }
}

void AudioRecorder::setAudioCodec(const QString &codec)
{
    QString _codec = codec;
    if (_codec == "default") {
        _codec = "audio/x-vorbis";
    }

    if (_codec != m_audioCodec) {
        m_audioCodec = _codec;
        emit audioCodecChanged();
    }
}

void AudioRecorder::setFileContainer(const QString &container)
{
    QString _container = container;
    if (_container == "default") {
        _container = "audio/ogg";
    }

    if (_container != m_fileContainer) {
        m_fileContainer = _container;
        emit fileContainerChanged();
    }
}

void AudioRecorder::setChannels(const int channels)
{
    if (channels != m_channels) {
        m_channels = channels;
        emit channelsChanged();
    }
}

void AudioRecorder::setEncodingMode(const AudioRecorder::EncodingMode mode)
{
    if (mode != m_encodingMode) {
        m_encodingMode = mode;
        emit encodingModeChanged();
    }
}

void AudioRecorder::setEncodingQuality(
        const AudioRecorder::EncodingQuality quality)
{
    if (quality != m_encodingQuality) {
        m_encodingQuality = quality;
        emit encodingQualityChanged();
    }
}

void AudioRecorder::setBitrate(const int bitrate)
{
    if (bitrate != m_bitrate) {
        m_bitrate = bitrate;
        emit bitrateChanged();
    }
}

QStringList AudioRecorder::supportedAudioCodecs()
{
    return m_audioRecorder->supportedAudioCodecs();
}

QStringList AudioRecorder::supportedContainers()
{
    return m_audioRecorder->supportedContainers();
}

//-----------------------------------------------------------------------------
// Public slots
//-----------------------------------------------------------------------------

void AudioRecorder::record()
{
    qDebug() << "codec:" << m_audioCodec << endl
             << "container:" << m_fileContainer << endl
             << "channels:" << m_channels << endl
             << "encodingMode:" << m_encodingMode << endl
             << "encodingQuality:" << m_encodingQuality << endl
             << "bitrate:" << m_bitrate << endl
             << "volume:" << m_audioRecorder->volume() << endl;

    m_audioRecorder->setVolume(m_microphoneVolume / 100.0);
    m_audioSettings.setCodec(m_audioCodec);
    if (m_audioCodec != "audio/x-vorbis") {
        m_audioSettings.setChannelCount(m_channels);
    }
    m_audioSettings.setEncodingMode((QMultimedia::EncodingMode)m_encodingMode);
    switch (m_encodingMode) {
    case QualityMode:
        m_audioSettings
                .setQuality((QMultimedia::EncodingQuality)m_encodingQuality);
        break;
    case BitrateMode:
        m_audioSettings.setBitRate(m_bitrate);
        break;
    }

    m_audioRecorder->setEncodingSettings(m_audioSettings);
    m_audioRecorder->setContainerFormat(m_fileContainer);

    QString absoluteFilePath = m_filePath + "/" + newFileName();
    m_audioRecorder->setOutputLocation(QUrl(absoluteFilePath));

    m_audioRecorder->record();
}

void AudioRecorder::pause()
{
    m_audioRecorder->pause();
}

void AudioRecorder::resume()
{
    m_audioRecorder->record();
}

void AudioRecorder::stop()
{
    m_audioRecorder->stop();
}

bool AudioRecorder::deleteRecordFile(const QString &fileName)
{
    qDebug() << "delete " << fileName;
    return QFile(fileName).remove();
}

bool AudioRecorder::renameRecordFile(const QString &fileName,
                                     const QString &newFileName)
{
    if (newFileName.isEmpty()) return false;

    return QFile(fileName).rename(m_filePath + "/" + newFileName);
}

//-----------------------------------------------------------------------------
// Private slots
//-----------------------------------------------------------------------------

void AudioRecorder::durationChanged(qint64 duration)
{
    emit recordTimeChanged(duration);
}

void AudioRecorder::displayErrorMessage() {
    qDebug() << "ERROR:" << m_audioRecorder->errorString();
    emit error(m_audioRecorder->errorString());
}

void AudioRecorder::stateChanged(QMediaRecorder::State state)
{
    qDebug() << "STATE:" << state;
    State st = StoppedState;
    switch (state) {
    case QMediaRecorder::StoppedState:
        st = StoppedState;
        break;
    case QMediaRecorder::RecordingState:
        st = RecordingState;
        break;
    case QMediaRecorder::PausedState:
        st = PausedState;
        break;
    }
    if (m_state != st) {
        m_state = st;
        emit recordStateChanged(m_state);
    }
}

void AudioRecorder::processBuffer(const QAudioBuffer& buffer)
{
    QVector<qreal> levels = getBufferLevels(buffer);
    for (int i = 0; i < levels.count(); ++i) {
        // qDebug() << i << levels.at(i);
        emit volumeLevelChanged(levels.at(i));
    }

    // qDebug() << QTime::currentTime().msec() << levels.count() << buffer.duration();

    return;
}

//-----------------------------------------------------------------------------
// Private methods
//-----------------------------------------------------------------------------

QString AudioRecorder::newFileName()
{
    QString dateStr = QDateTime::currentDateTime()
            .toString("yyyy-MM-dd-hh-mm-ss-zzz");
    QString fileExtension;
    if (m_fileContainer == "matroska") {
        fileExtension = "mkv";
    } else if (m_fileContainer == "audio/ogg") {
        fileExtension = "ogg";
    } else if (m_fileContainer == "wav") {
        fileExtension = "wav";
    } else if (m_fileContainer == "avi") {
        fileExtension = "avi";
    } else if (m_fileContainer == "3gpp") {
        fileExtension = "3gp";
    } else if (m_fileContainer == "flv") {
        fileExtension = "flv";
    } else if (m_fileContainer == "raw") {
        fileExtension = "raw";
    } else {
        fileExtension = "ogg";
    }
    m_fileName = dateStr + "." + fileExtension;
    emit fileNameChanged();
    return m_fileName;
}

// This function returns the maximum possible sample value for a given audio format
qreal getPeakValue(const QAudioFormat& format)
{
    // Note: Only the most common sample formats are supported
    if (!format.isValid())
        return qreal(0);

    if (format.codec() != "audio/pcm")
        return qreal(0);

    switch (format.sampleType()) {
    case QAudioFormat::Unknown:
        break;
    case QAudioFormat::Float:
        if (format.sampleSize() != 32) // other sample formats are not supported
            return qreal(0);
        return qreal(1.00003);
    case QAudioFormat::SignedInt:
        if (format.sampleSize() == 32)
            return qreal(INT_MAX);
        if (format.sampleSize() == 16)
            return qreal(SHRT_MAX);
        if (format.sampleSize() == 8)
            return qreal(CHAR_MAX);
        break;
    case QAudioFormat::UnSignedInt:
        if (format.sampleSize() == 32)
            return qreal(UINT_MAX);
        if (format.sampleSize() == 16)
            return qreal(USHRT_MAX);
        if (format.sampleSize() == 8)
            return qreal(UCHAR_MAX);
        break;
    }

    return qreal(0);
}

// returns the audio level for each channel
QVector<qreal> getBufferLevels(const QAudioBuffer& buffer)
{
    QVector<qreal> values;

    if (!buffer.format().isValid() || buffer.format().byteOrder() != QAudioFormat::LittleEndian)
        return values;

    if (buffer.format().codec() != "audio/pcm")
        return values;

    int channelCount = buffer.format().channelCount();
    values.fill(0, channelCount);
    qreal peak_value = getPeakValue(buffer.format());
    if (qFuzzyCompare(peak_value, qreal(0)))
        return values;

    switch (buffer.format().sampleType()) {
    case QAudioFormat::Unknown:
    case QAudioFormat::UnSignedInt:
        if (buffer.format().sampleSize() == 32)
            values = getBufferLevels(buffer.constData<quint32>(), buffer.frameCount(), channelCount);
        if (buffer.format().sampleSize() == 16)
            values = getBufferLevels(buffer.constData<quint16>(), buffer.frameCount(), channelCount);
        if (buffer.format().sampleSize() == 8)
            values = getBufferLevels(buffer.constData<quint8>(), buffer.frameCount(), channelCount);
        for (int i = 0; i < values.size(); ++i)
            values[i] = qAbs(values.at(i) - peak_value / 2) / (peak_value / 2);
        break;
    case QAudioFormat::Float:
        if (buffer.format().sampleSize() == 32) {
            values = getBufferLevels(buffer.constData<float>(), buffer.frameCount(), channelCount);
            for (int i = 0; i < values.size(); ++i)
                values[i] /= peak_value;
        }
        break;
    case QAudioFormat::SignedInt:
        if (buffer.format().sampleSize() == 32)
            values = getBufferLevels(buffer.constData<qint32>(), buffer.frameCount(), channelCount);
        if (buffer.format().sampleSize() == 16)
            values = getBufferLevels(buffer.constData<qint16>(), buffer.frameCount(), channelCount);
        if (buffer.format().sampleSize() == 8)
            values = getBufferLevels(buffer.constData<qint8>(), buffer.frameCount(), channelCount);
        for (int i = 0; i < values.size(); ++i)
            values[i] /= peak_value;
        break;
    }

    return values;
}

template <class T>
QVector<qreal> getBufferLevels(const T *buffer, int frames, int channels)
{
    QVector<qreal> max_values;
    max_values.fill(0, channels);

    for (int i = 0; i < frames; ++i) {
        for (int j = 0; j < channels; ++j) {
            qreal value = qAbs(qreal(buffer[i * channels + j]));
            if (value > max_values.at(j))
                max_values.replace(j, value);
        }
    }

    return max_values;
}

